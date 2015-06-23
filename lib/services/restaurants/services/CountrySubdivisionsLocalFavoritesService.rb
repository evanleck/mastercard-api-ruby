require_relative '../../../common/connector'
require_relative '../../../common/environment'
require_relative '../../../common/url_util'
require_relative '../../../services/restaurants/domain/country_subdivisions/CountrySubdivision'
require_relative '../../../services/restaurants/domain/country_subdivisions/CountrySubdivisions'

require 'rexml/document'
include REXML
include Mastercard::Common
include Mastercard::Services::Restaurants

module Mastercard
  module Services
    module Restaurants

      class CountrySubdivisionsLocalFavoritesService < Connector

        SANDBOX_URL = 'https://sandbox.api.mastercard.com/restaurants/v1/countrysubdivision?Format=XML'
        PRODUCTION_URL = 'https://api.mastercard.com/restaurants/v1/countrysubdivision?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_country_subdivisions(options)
          url = get_url(options)
          doc = Document.new(do_request(url, 'GET'))
          generate_return_object(doc)
        end

        def get_url(options)
          url_util = URLUtil.new
          url = SANDBOX_URL.dup
          if @environment == PRODUCTION
            url = PRODUCTION_URL.dup
          end
          url = url_util.add_query_parameter(url, 'Country', options.country)
        end

        def generate_return_object(xml_body)
          xml_country_subdivisions = xml_body.elements.to_a('CountrySubdivisions/CountrySubdivision')
          country_subdivision_array = Array.new
          xml_country_subdivisions.each do|xml_country_subdivision|
            country_subdivision = CountrySubdivision.new(
            xml_country_subdivision.elements['Name'].text,
            xml_country_subdivision.elements['Code'].text
            )
            country_subdivision_array.push(country_subdivision)
          end
          country_subdivisions = CountrySubdivisions.new(country_subdivision_array)
        end

      end

    end
  end
end