require_relative '../../../common/connector'
require_relative '../../../common/environment'
require_relative '../../../common/url_util'
require_relative '../../../services/restaurants/domain/restaurant/Restaurants'
require_relative '../../../services/restaurants/domain/restaurant/Restaurant'
require_relative '../../../services/restaurants/domain/restaurant/Address'
require_relative '../../../services/restaurants/domain/restaurant/Location'
require_relative '../../../services/restaurants/domain/countries/Country'
require_relative '../../../services/restaurants/domain/country_subdivisions/CountrySubdivision'
require_relative '../../../services/restaurants/domain/restaurant/Point'

require 'rexml/document'
include REXML
include Mastercard::Common
include Mastercard::Services::Restaurants

module Mastercard
  module Services
    module Restaurants

      class RestaurantsLocalFavoritesService < Connector

        SANDBOX_URL = 'https://sandbox.api.mastercard.com/restaurants/v1/restaurant?Format=XML'
        PRODUCTION_URL = 'https://api.mastercard.com/restaurants/v1/restaurant?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_restaurants(options)
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
          url = url_util.add_query_parameter(url, 'PageOffset', options.page_offset)
          url = url_util.add_query_parameter(url, 'PageLength', options.page_length)
          url = url_util.add_query_parameter(url, 'Category', options.category)
          url = url_util.add_query_parameter(url, 'AddressLine1', options.address_line1)
          url = url_util.add_query_parameter(url, 'AddressLine2', options.address_line2)
          url = url_util.add_query_parameter(url, 'City', options.city)
          url = url_util.add_query_parameter(url, 'CountrySubdivision', options.country_subdivision)
          url = url_util.add_query_parameter(url, 'PostalCode', options.postal_code)
          url = url_util.add_query_parameter(url, 'Country', options.country)
          url = url_util.add_query_parameter(url, 'Latitude', options.latitude)
          url = url_util.add_query_parameter(url, 'Longitude', options.longitude)
          url = url_util.add_query_parameter(url, 'DistanceUnit', options.distance_unit)
          url = url_util.add_query_parameter(url, 'Radius', options.radius)
        end

        def generate_return_object(xml_body)
            restaurant_array = Array.new
            xml_restaurants = xml_body.elements.to_a('Restaurants/Restaurant')
            xml_restaurants.each do |restaurant|
                tmp_restaurant = Restaurant.new
                tmp_restaurant.id = restaurant.elements['Id'].text
                tmp_restaurant.name = restaurant.elements['Name'].text
                tmp_restaurant.website_url = restaurant.elements['WebsiteUrl'].text
                tmp_restaurant.phone_number = restaurant.elements['PhoneNumber'].text
                tmp_restaurant.category = restaurant.elements['Category'].text
                tmp_restaurant.local_favorite_ind = restaurant.elements['LocalFavoriteInd'].text
                tmp_restaurant.hidden_gem_ind = restaurant.elements['HiddenGemInd'].text

                tmp_location = Location.new
                location = restaurant.elements['Location']
                tmp_location.name = location.elements['Name'].text
                tmp_location.distance = location.elements['Distance'].text
                tmp_location.distance_unit = location.elements['DistanceUnit'].text

                tmp_address = Address.new
                address = location.elements['Address']
                tmp_address.line1 = address.elements['Line1'].text
                tmp_address.line2 = address.elements['Line2'].text
                tmp_address.city = address.elements['City'].text
                tmp_address.postal_code = address.elements['PostalCode'].text

                tmp_country = Country.new(
                address.elements['Country/Name'].text,
                address.elements['Country/Code'].text
                )

                tmp_country_subdivision = CountrySubdivision.new(
                address.elements['CountrySubdivision/Name'].text,
                address.elements['CountrySubdivision/Code'].text
                )

                tmp_address.country = tmp_country
                tmp_address.country_subdivision = tmp_country_subdivision

                tmp_point = Point.new
                point = location.elements['Point']
                tmp_point.latitude = point.elements['Latitude'].text
                tmp_point.longitude = point.elements['Longitude'].text

                tmp_location.point = tmp_point
                tmp_location.address = tmp_address
                tmp_restaurant.location = tmp_location
                restaurant_array.push(tmp_restaurant)
            end
            restaurants = Restaurants.new(
            xml_body.elements['Restaurants/PageOffset'].text,
            xml_body.elements['Restaurants/TotalCount'].text,
            restaurant_array
            )
        end

      end
    end
  end
end