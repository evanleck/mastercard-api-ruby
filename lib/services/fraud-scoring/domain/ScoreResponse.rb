module Mastercard
  module Services
    module FraudScoring

      class ScoreResponse

        attr_accessor :match_indicator
        attr_accessor :fraud_score
        attr_accessor :reason_code
        attr_accessor :rules_adjusted_score
        attr_accessor :rules_adjusted_reason_code
        attr_accessor :rules_adjusted_reason_code_secondary

      end
    end
  end
end