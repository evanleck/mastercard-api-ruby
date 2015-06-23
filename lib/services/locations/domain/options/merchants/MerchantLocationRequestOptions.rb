module Mastercard
  module Services
    module Locations

      class MerchantLocationRequestOptions

        MILE = 'mile'
        KILOMETER = 'kilometer'

        attr_accessor :details
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
        attr_accessor :offer_merchant_id

        def initialize(details, page_offset, page_length)
          @details, @page_offset, @page_length = details, page_offset, page_length
        end

      end

    end
  end
end