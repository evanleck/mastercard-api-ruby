require_relative '../../../common/connector'
require_relative '../../../common/environment'
require_relative '../../../common/url_util'
require_relative '../../../services/restaurants/domain/countries/Country'
require_relative '../../../services/restaurants/domain/countries/Countries'

require 'rexml/document'
include REXML
include Mastercard::Common
include Mastercard::Services::Restaurants

module Mastercard
  module Services
    module Restaurants

      class CountriesLocalFavoritesService < Connector

        SANDBOX_URL = 'https://sandbox.api.mastercard.com/restaurants/v1/country?Format=XML'
        PRODUCTION_URL = 'https://api.mastercard.com/restaurants/v1/country?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_countries()
          url = get_url()
          doc = Document.new(do_request(url, 'GET'))
          generate_return_object(doc)
        end

        def get_url()
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
            country = Country.new(
            xml_country.elements['Name'].text,
            xml_country.elements['Code'].text
            )
            country.geo_coding = xml_country.elements['Geocoding'].text
            country_array.push(country)
          end
          countries = Countries.new(country_array)
        end

      end

    end
  end
end