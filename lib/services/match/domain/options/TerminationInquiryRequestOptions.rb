module Mastercard
  module Services
    module Match

      class TerminationInquiryRequestOptions

        attr_reader :page_offset
        attr_reader :page_length

        def initialize(page_offset, page_length)
          @page_offset, @page_length = page_offset, page_length
          if @page_length > 25
             @page_length = 25
          end
        end

      end

    end
  end
end