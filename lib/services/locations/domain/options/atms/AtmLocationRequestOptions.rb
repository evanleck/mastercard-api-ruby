module Mastercard
  module Services
    module Locations

      class AtmLocationRequestOptions

        KILOMETER = 'KILOMETER'
        MILE = 'MILE'
        SUPPORT_EMV_YES = 1
        SUPPORT_EMV_NO = 2
        SUPPORT_EMV_UNKNOWN = 0
        INTERNATIONAL_MAESTRO_ACCEPTED_YES = 1

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
        attr_accessor :support_emv
        attr_accessor :international_maestro_accepted

        def initialize(page_offset, page_length)
          @page_offset, @page_length = page_offset, page_length
        end

      end

    end
  end
end