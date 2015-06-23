module Mastercard
  module Services
    module Locations

      class CountrySubdivisionMerchantLocationRequestOptions

        attr_reader :details
        attr_reader :country

        def initialize(details, country)
          @details, @country = details, country
        end

      end

    end
  end
end