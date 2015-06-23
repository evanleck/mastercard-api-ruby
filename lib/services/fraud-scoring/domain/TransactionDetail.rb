module Mastercard
  module Services
    module FraudScoring

      class TransactionDetail

        attr_accessor :customer_identifier
        attr_accessor :merchant_identifier
        attr_accessor :account_number
        attr_accessor :account_prefix
        attr_accessor :account_suffix
        attr_accessor :transaction_amount
        attr_accessor :transaction_date
        attr_accessor :transaction_time
        attr_accessor :bank_net_reference_number
        attr_accessor :stan

      end

    end
  end
end