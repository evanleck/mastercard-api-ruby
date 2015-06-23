module Mastercard
  module Services
    module Match

      class TerminationInquiryRequestType

        attr_accessor :acquirer_id
        attr_accessor :transaction_reference_number
        attr_accessor :merchant

        def initialize(acquirer_id, merchant)
          @acquirer_id, @merchant = acquirer_id, merchant
        end

      end

    end
  end
end
