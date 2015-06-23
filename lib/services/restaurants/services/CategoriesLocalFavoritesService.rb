require_relative '../../../common/connector'
require_relative '../../../common/environment'
require_relative '../../../common/url_util'
require_relative '../../restaurants/domain/categories/Categories'

require 'rexml/document'
include REXML
include Mastercard::Common

module Mastercard
  module Services
    module Restaurants

      class CategoriesLocalFavoritesService < Connector

        SANDBOX_URL = 'https://sandbox.api.mastercard.com/restaurants/v1/category?Format=XML'
        PRODUCTION_URL = 'https://api.mastercard.com/restaurants/v1/category?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_categories
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
          xml_categories = xml_body.elements.to_a('Categories/Category')
          category_array = Array.new
          xml_categories.each do|xml_category|
            category_array.push(xml_category.text)
          end
          categories = Categories.new
          categories.category = category_array
          categories
        end

      end

    end
  end
end