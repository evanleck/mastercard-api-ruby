module Mastercard
  module Services
    module MerchantIdentifier

      class RequestOptions

        attr_reader :merchant_id
        attr_accessor :type

        def initialize(merchant_id)
          @merchant_id = merchant_id
        end

        def set_type(type)
          @type = type
        end

      end

    end
  end
end
