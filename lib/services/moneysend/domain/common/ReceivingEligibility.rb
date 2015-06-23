module Mastercard
  module Services
    module MoneySend

      class ReceivingEligibility

        attr_accessor :eligible
        attr_accessor :reason_code
        attr_accessor :account_number
        attr_accessor :ica
        attr_accessor :currency
        attr_accessor :country
        attr_accessor :brand

      end

    end
  end
end
