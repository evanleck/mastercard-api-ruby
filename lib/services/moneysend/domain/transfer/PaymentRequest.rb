module Mastercard
  module Services
    module MoneySend

      class PaymentRequest

        attr_accessor :local_date
        attr_accessor :local_time
        attr_accessor :transaction_reference
        attr_accessor :sender_name
        attr_accessor :sender_address
        attr_accessor :receiving_card
        attr_accessor :receiving_mapped
        attr_accessor :receiving_amount
        attr_accessor :ica
        attr_accessor :processor_id
        attr_accessor :routing_and_transit_number
        attr_accessor :card_acceptor
        attr_accessor :transaction_desc
        attr_accessor :merchant_id

      end

    end
  end
end
