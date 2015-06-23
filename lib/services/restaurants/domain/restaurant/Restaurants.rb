module Mastercard
  module Services
    module Restaurants

      class Restaurants

        attr_accessor :page_offset
        attr_accessor :total_count
        attr_accessor :restaurant

        def initialize(page_offset, total_count, restaurant)
          @page_offset, @total_count, @restaurant = page_offset, total_count, restaurant
        end

      end

    end
  end
end