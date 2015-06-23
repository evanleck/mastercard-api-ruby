module Mastercard
  module Services
    module MoneySend

      class Transaction

        attr_accessor :type
        attr_accessor :system_trace_audit_number
        attr_accessor :network_reference_number
        attr_accessor :settlement_date
        attr_accessor :response
        attr_accessor :submit_date_time

      end

    end
  end
end
