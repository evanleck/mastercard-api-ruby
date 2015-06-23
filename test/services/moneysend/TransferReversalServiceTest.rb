require_relative '../../test_helper'
require 'test/unit'

include Mastercard::Common
include Mastercard::Util
include Mastercard::Services::MoneySend

class TransferReversalServiceTest < Test::Unit::TestCase

  def setup
    @transfer_service = TransferService.new(SANDBOX_CONSUMER_KEY, TestUtils.new.get_private_key(SANDBOX), SANDBOX)
    @service = TransferReversalService.new(SANDBOX_CONSUMER_KEY, TestUtils.new.get_private_key(SANDBOX), SANDBOX)
  end

  def test_transfer_reversal_service
    trans_ref = transaction_ref_generator

    transfer_request_card = TransferRequest.new
    transfer_request_card.local_date = '1212'
    transfer_request_card.local_time = '161222'
    transfer_request_card.transaction_reference = trans_ref
    transfer_request_card.sender_name = 'John Doe'

    sender_address = SenderAddress.new
    sender_address.line1 = '123 Main Street'
    sender_address.line2 = '#5A'
    sender_address.city = 'Arlington'
    sender_address.country_subdivision = 'VA'
    sender_address.postal_code = '22207'
    sender_address.country = 'USA'
    transfer_request_card.sender_address = sender_address

    funding_card = FundingCard.new
    funding_card.account_number = '5184680430000014'
    funding_card.expiry_month = '11'
    funding_card.expiry_year = '2014'
    transfer_request_card.funding_card = funding_card

    transfer_request_card.funding_ucaf = 'MjBjaGFyYWN0ZXJqdW5rVUNBRjU=1111'
    transfer_request_card.funding_mastercard_assigned_id = '123456'

    funding_amount = FundingAmount.new
    funding_amount.value = '15500'
    funding_amount.currency = '840'
    transfer_request_card.funding_amount = funding_amount

    transfer_request_card.receiver_name = 'Jose Lopez'

    receiver_address = ReceiverAddress.new
    receiver_address.line1 = 'Pueblo Street'
    receiver_address.line2 = 'PO BOX 12'
    receiver_address.city = 'El PASO'
    receiver_address.country_subdivision = 'TX'
    receiver_address.postal_code = '79906'
    receiver_address.country = 'USA'
    transfer_request_card.receiver_address = receiver_address

    transfer_request_card.receiver_phone = '1800639426'

    receiving_card = ReceivingCard.new
    receiving_card.account_number = '5184680430000006'
    transfer_request_card.receiving_card = receiving_card

    receiving_amount = ReceivingAmount.new
    receiving_amount.value = '182206'
    receiving_amount.currency = '484'
    transfer_request_card.receiving_amount = receiving_amount

    transfer_request_card.channel = 'W'
    transfer_request_card.ucaf_support = 'false'
    transfer_request_card.ica = '009674'
    transfer_request_card.processor_id = '9000000442'
    transfer_request_card.routing_and_transit_number = '990442082'

    card_acceptor = CardAcceptor.new
    card_acceptor.name = 'My Local Bank'
    card_acceptor.city = 'Saint Louis'
    card_acceptor.state = 'MO'
    card_acceptor.postal_code = '63101'
    card_acceptor.country = 'USA'
    transfer_request_card.card_acceptor = card_acceptor

    transfer_request_card.transaction_desc = 'P2P'
    transfer_request_card.merchant_id = '123456'

    transfer = @transfer_service.get_transfer(transfer_request_card)
    assert(transfer != nil, 'true')
    assert(transfer.transaction_reference.to_i > 0, 'true')
    assert(transfer.transaction_history.transaction[0] != nil, 'true')
    assert(transfer.transaction_history.transaction[0].response.code.to_i == 00, 'true')
    assert(transfer.transaction_history.transaction[1].response.code.to_i == 00, 'true')

    transfer_reversal_request = TransferReversalRequest.new
    transfer_reversal_request.ica = '009674'

    transfer_reversal_request.transaction_reference = transfer.transaction_reference

    transfer_reversal_request.reversal_reason = 'FAILURE IN PROCESSING'
    transfer_reversal = @service.get_transfer_reversal(transfer_reversal_request)
    assert(transfer_reversal.request_id != nil, 'true')
    assert(transfer_reversal.transaction_reference != nil, 'true')
    assert(transfer_reversal.transaction_history.transaction.response.code.to_i == 00, 'true')
  end

  def transaction_ref_generator
    a = 0
    loop do
      p a = rand(2**32..2**64-1).to_s
      a = a[0..a.length-1]
      break if a.length == 19
    end
    a
  end

end
