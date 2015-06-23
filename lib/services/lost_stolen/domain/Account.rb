module Mastercard
  module Services
    module LostStolen

      class Account

        attr_reader :status
        attr_reader :listed
        attr_reader :reason_code
        attr_reader :reason

        def initialize(status, listed, reason_code, reason)
          @status, @listed, @reason_code, @reason = status, listed, reason_code, reason
        end

      end

    end
  end
end

