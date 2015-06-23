module Mastercard
  module Services
    module MerchantIdentifier

      class ReturnedMerchants

        attr_accessor :merchant

        def initialize(merchant)
          @merchant = merchant
        end

      end

    end
  end
end
