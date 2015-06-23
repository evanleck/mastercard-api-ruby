require_relative '../../common/connector'
require_relative '../../common/environment'
require_relative 'domain/Account'

require 'rexml/document'
include REXML
include Mastercard::Common
include Mastercard::Services::LostStolen

module Mastercard
  module Services
    module LostStolen

      class LostStolenService < Connector

        PRODUCTION_URL = 'https://api.mastercard.com/fraud/loststolen/v1/account-inquiry?Format=XML'
        SANDBOX_URL = 'https://sandbox.api.mastercard.com/fraud/loststolen/v1/account-inquiry?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_account(account_number)
          body = generate_xml(account_number)
          url = get_url
          doc = Document.new(do_request(url, 'PUT', body))
          generate_return_object(doc)
        end

        def generate_xml(account_number)
          doc = Document.new
          doc << XMLDecl.new(1.0, 'ISO-8859-15')
          root = doc.add_element(generate_inner_xml(account_number))
          doc.to_s
        end

        def generate_inner_xml(account_number)
          el = Element.new('AccountInquiry')
          el.add_element('AccountNumber').add_text(account_number)
          el
        end

        def get_url()
          url = SANDBOX_URL
          if @environment == PRODUCTION
            url = PRODUCTION_URL
          end
          url
        end

        def generate_return_object(xml_body)
          account = xml_body.elements['Account']
          status = account.elements['Status'].text
          listed = account.elements['Listed'].text
          reason_code = account.elements['ReasonCode'].text
          reason = account.elements['Reason'].text
          Account.new(status, listed, reason_code, reason)
        end

      end

    end
  end
end

