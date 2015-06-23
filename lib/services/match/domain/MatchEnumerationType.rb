module Mastercard
  module Services
    module Match

      class MatchEnumerationType

        attr_reader :exact
        attr_reader :phonetic
        attr_reader :none

        exact = 'exact'
        phonetic = 'phonetic'
        none = 'none'

      end
    end
  end
end
