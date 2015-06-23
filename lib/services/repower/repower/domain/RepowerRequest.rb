module Mastercard
  module Services
    module Repower

      class RepowerRequest

        attr_accessor :transaction_reference
        attr_accessor :card_number
        attr_accessor :transaction_amount
        attr_accessor :local_date
        attr_accessor :local_time
        attr_accessor :channel
        attr_accessor :ica
        attr_accessor :processor_id
        attr_accessor :routing_and_transit_number
        attr_accessor :merchant_type
        attr_accessor :card_acceptor

      end

    end
  end
end
