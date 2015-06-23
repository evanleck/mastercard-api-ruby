require 'base64'
require 'cgi'
require 'net/http'
require 'net/https'
require 'openssl'
require 'digest/sha1'
require 'securerandom'
require_relative '../common/oauth_parameters'
require_relative '../common/oauth_constants'

module Mastercard
  module Common

    class Connector

      attr_accessor :signature_base_string
      attr_accessor :auth_header
      attr_accessor :signed_signature_base_string
      
      NONCE_LENGTH = 8 
      VALID_CHARS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
      
      OAUTH_START_STRING = 'OAuth '
      ERROR_STATUS_BOUNDARY = 300
      EMPTY_STRING = ""
      
      POST = "POST"
      GET = "GET"
      DELETE = "DELETE"
      PUT = "PUT"
      UTF_8 = "UTF-8"
      EQUALS = "="
      AMP = '&'
      COLON_2X_BACKSLASH = "://"
      MESSAGE = "Message"
      HTTP_CODE = "HttpCode"

      USER_AGENT = 'MC API OAuth Framework v1.0-Ruby'
             
=begin
      consumer_key = Key provided by MasterCard upon registering
      private_key = private key object
=end
      def initialize(consumer_key, private_key)
        @consumer_key = consumer_key
        @private_key = private_key
        @signature_base_string = ''
        @auth_header = ''
        @signed_signature_base_string = ''
      end
=begin
      Method to generate base OAuth params
=end
      def oauth_parameters_factory
        oparams = Mastercard::Common::OAuthParameters.new
        oparams.add_parameter(OAUTH_CONSUMER_KEY, @consumer_key)
        oparams.add_parameter(OAUTH_NONCE, generate_nonce)
        oparams.add_parameter(OAUTH_TIMESTAMP, generate_timestamp)
        oparams.add_parameter(OAUTH_SIGNATURE_METHOD, "RSA-SHA1")
        oparams.add_parameter(OAUTH_VERSION, "1.0")
        oparams
      end
      
=begin
      Method to perform a request.  Only Connector subclasses should access this method.
      url - URL to connect to, includes query string parameters
      body - XML body to send to MasterCard for PUT/POST/DELETE
      oauth_params - often nil, may be populated for testing
=end
      def do_request(url, request_method, body = nil, oauth_params = nil)
        if @consumer_key == nil
          raise 'Consumer Key may not be nil.'
        end

        if @private_key == nil
          raise 'Private Key may not be nil.'
        end
        if oauth_params == nil
          oauth_params = oauth_parameters_factory
        end
        
        if body != nil && body.length > 0
          oauth_params = generate_body_hash(body, oauth_params)
        end
        response = connect(url, request_method, oauth_params, body)
        check_response(response)
        response.body
      end
=begin
      Method to connect via HTTP. This method subsequesntly builds and signs the Oauth
      Header
=end        
      def connect(url, request_method, oauth_params, body=nil)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        if request_method.upcase == 'GET'
          request = Net::HTTP::Get.new(uri.request_uri)
        elsif request_method.upcase == 'PUT'
          request = Net::HTTP::Put.new(uri.request_uri)
        elsif request_method.upcase == 'POST'
          request = Net::HTTP::Post.new(uri.request_uri)
        elsif request_method.upcase == 'DELETE'
          request = Net::HTTP::Delete.new(uri.request_uri)
        else
          raise 'Unsupported HTTP Action.'
        end

        if body != nil
          add_headers(url, request, request_method, oauth_params, body)
          request.body = body
        else
          add_headers(url, request, request_method, oauth_params)
        end
        http.request(request)
      end
=begin
      Method to build the OAuth headers.
=end
      def add_headers(url, request, request_method, oauth_params, body=nil)
        auth_header = build_auth_header_string(url, request_method, oauth_params)
        request['Authorization'] = auth_header
        request['User-Agent'] = USER_AGENT
        if body != nil
          request['content-type'] = 'application/xml;charset=UTF-8'
          body_length = body.length
          request['content-length'] = body_length.to_s
        end
        request
      end
=begin
            Method to build the auth header for the HTTP request.
            oauth_params - full populated oauth parameters
=end
      def build_auth_header_string(url, request_method, oauth_params)
        temp_params = Mastercard::Common::OAuthParameters.new
        oauth_params_key_arr = oauth_params.params.keys.sort
        oauth_params_key_arr.each do |p|
          temp_params.add_parameter(p, oauth_params.send(p)) if p != :realm
        end
        generate_signature_base_string(url, request_method, temp_params) 
        sign(oauth_params)
        header = ''
        oauth_params_key_arr = oauth_params.params.keys.sort
        oauth_params_key_arr.each do |p|
          header << p.to_s << '="' << oauth_params.send(p) << '",' if oauth_params.send(p)
        end
        header = '' << OAUTH_START_STRING << header
        #remove trailing comma
        header = header[0...header.length-1]
        header
      end
=begin
      Method to sign the signature base string using the private key.
=end
      def sign(oauth_params)
        if @signature_base_string == nil || @signature_base_string.length == 0
          raise 'Signature Base String May Not Be Null.'
        end
        digest = OpenSSL::Digest::SHA1.new
        @signed_signature_base_string =  CGI.escape(Base64.encode64(@private_key.sign(digest,@signature_base_string)))
        @signed_signature_base_string.gsub!('+','%20')
        @signed_signature_base_string.gsub!('*','%2A')
        @signed_signature_base_string.gsub!('~','%7E')

        oauth_params.add_parameter('oauth_signature' , @signed_signature_base_string)
      end
=begin
      Method to generate the signature base string from the url, HTTP request method, and oauth_params
      url - URL, including query string parameters, to access
      request_method - case-insensitive HTTP request method, e.g. GET, POST, PUT, DELETE
      oauth_params - populated oauth parameters object
=end
      def generate_signature_base_string(url, request_method, oauth_params)
        @signature_base_string =
            CGI.escape(request_method.upcase) << AMP << CGI.escape(normalize_url(url)) << AMP << CGI.escape(normalize_parameters(url, oauth_params))
        puts @signature_base_string
      end
=begin
      Method to return "core" URL for signature base string generation.  http://somesite.com:8080?blah becomes http://somesite.com, for example
      url - URL to normalize
=end
      def normalize_url(url)
        tmp = url.clone
        # strip query string section
        idx = tmp.index('?')
        if idx != nil
          tmp = tmp[0..idx-1]
        end
        # strip port
        if tmp.rindex(':') != nil && tmp.rindex(':') > 5 # implies port is given
          tmp = tmp[0..tmp.rindex(':')-1]
        end
        tmp
      end
=begin
      The signature base string must be in lexical order prior to signing. This method does that required work.
      url - url to access
      oauth_params - OAuthParameters object used for building Signature Base String
=end
      def normalize_parameters(url, oauth_params)
        oauth_params_hash = oauth_params.params
        oauth_params_key_arr = oauth_params_hash.keys.sort
        if url.include? "?"
          query_params_hash = CGI.parse(URI.parse(url).query)
          query_params_arr = query_params_hash.keys.sort
          query = true
        else
          query_params_hash = {}
          query_params_arr = []
          query = false
        end
        oauth_param = ''
        param = ''
        delimiter = ''

        oauth_params_key_arr.each do |k|
            oauth_param << delimiter << k.to_s << '=' << oauth_params_hash[k]
            delimiter = "&"
        end

        delimiter = ''

        if query
          query_params_arr.each do |q|
             param << delimiter << q.to_s << '=' << query_params_hash[q][0]
            delimiter = '&'
          end
        end
        #else

        param << delimiter << oauth_param
        param.gsub(' ', '%20')
      end
       
      def check_response(response)
        if response.code.to_i >= ERROR_STATUS_BOUNDARY
          raise 'Response Code: ' << response.code.to_s << "\n" << response.body
        end
      end
      
      # if a body is present for sending to server, needs hashed as part of OAuth spec
      def generate_body_hash(body, oauth_params)
        if body != nil
          oauth_body_hash = Digest::SHA1.base64digest(body)
          oauth_params.add_parameter(:oauth_body_hash, oauth_body_hash)
        end
        oauth_params
      end
      
      # unique identifier for given timestamp (in seconds)
      def generate_nonce
        str = ''
        for i in 1..NONCE_LENGTH
          str << VALID_CHARS[SecureRandom.random_number(VALID_CHARS.length)]
        end
        @oauth_nonce = str
      end
      # number of seconds since epoch
      def generate_timestamp
        @oauth_timestamp = Time.now.to_i.to_s
      end
    end 
  end
end