module Mastercard
  module Services
    module Match

      class TerminationInquiry

        attr_accessor :page_offset
        attr_accessor :total_length
        attr_accessor :ref
        attr_accessor :transaction_reference_number
        attr_accessor :terminated_merchant

        def initialize(page_offset, total_length, ref, terminated_merchant)
          @page_offset, @total_length, @ref, @terminated_merchant = page_offset, total_length, ref, terminated_merchant
        end

        def get_reference_id
          if ref != nil
            ref[/([^\/]+)$/]
          else
            ''
          end
        end

      end

    end
  end
end
