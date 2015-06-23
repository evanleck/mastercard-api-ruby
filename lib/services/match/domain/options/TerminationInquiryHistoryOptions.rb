module Mastercard
  module Services
    module Match

      class TerminationInquiryHistoryOptions

        attr_reader :page_offset
        attr_reader :page_length
        attr_reader :acquirer_id
        attr_reader :inquiry_reference_number

        def initialize(page_offset, page_length, acquirer_id, inquiry_reference_number)
          @page_offset, @page_length, @acquirer_id, @inquiry_reference_number = page_offset, page_length, acquirer_id, inquiry_reference_number
          if @page_length > 25
            @page_length = 25
          end
        end

      end

    end
  end
end

