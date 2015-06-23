module Mastercard
  module Services
    module Restaurants

      class RestaurantsLocalFavoritesRequestOptions

        KILOMETER = 'KILOMETER'
        MILE = 'MILE'

        attr_accessor :page_offset
        attr_accessor :page_length
        attr_accessor :category
        attr_accessor :address_line1
        attr_accessor :address_line2
        attr_accessor :city
        attr_accessor :country_subdivision
        attr_accessor :postal_code
        attr_accessor :country
        attr_accessor :latitude
        attr_accessor :longitude
        attr_accessor :distance_unit
        attr_accessor :radius

        def initialize(page_offset, page_length)
          @page_offset, @page_length = page_offset, page_length
          if page_length > 25
            page_length = 25
          end
        end

      end

    end
  end
end