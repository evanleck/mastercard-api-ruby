module Mastercard
  module Services
    module FraudScoring

      class ScoreLookup

        attr_accessor :customer_identifier
        attr_accessor :request_timestamp
        attr_accessor :transaction_detail
        attr_accessor :score_response

      end

    end
  end
end