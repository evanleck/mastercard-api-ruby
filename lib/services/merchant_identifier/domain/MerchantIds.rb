module Mastercard
  module Services
    module MerchantIdentifier

      class MerchantIds

        attr_accessor :message
        attr_accessor :returned_merchants

        def initialize(message, returned_merchants)
          @message, @returned_merchants = message, returned_merchants
        end

      end

    end
  end
end
