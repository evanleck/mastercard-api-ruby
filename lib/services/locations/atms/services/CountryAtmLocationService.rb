require_relative '../../../../common/Connector'
require_relative '../../../../common/Environment'
require_relative '../../../../common/url_util'
require_relative '../../../../services/locations/domain/common/countries/countries'
require_relative '../../../../services/locations/domain/common/countries/Country'

require 'rexml/document'
include REXML
include Mastercard::Common
include Mastercard::Services::Locations

module Mastercard
  module Services
    module Locations

      class CountryAtmLocationService < Connector

        SANDBOX_URL = 'https://sandbox.api.mastercard.com/atms/v1/country?Format=XML'
        PRODUCTION_URL = 'https://api.mastercard.com/atms/v1/country?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_countries
          url = get_url
          doc = Document.new(do_request(url, 'GET'))
          generate_return_object(doc)
        end

        def get_url
          url = SANDBOX_URL.dup
          if @environment == PRODUCTION
            url = PRODUCTION_URL.dup
          end
          url
        end

        def generate_return_object(xml_body)
          xml_countries = xml_body.elements.to_a('Countries/Country')
          country_array = Array.new
          xml_countries.each do|xml_country|
            country = Country.new
            country.name = xml_country.elements['Name'].text
            country.code = xml_country.elements['Code'].text
            country.geo_coding = xml_country.elements['Geocoding'].text
            country_array.push(country)
          end
          countries = Countries.new(country_array)
        end

      end
    end
  end
end