require_relative '../../test_helper'
require 'test/unit'

include Mastercard::Common
include Mastercard::Util
include Mastercard::Services::MoneySend

class TransferServiceTest < Test::Unit::TestCase

  def setup
    @service = TransferService.new(SANDBOX_CONSUMER_KEY, TestUtils.new.get_private_key(SANDBOX), SANDBOX)
  end

  def test_transfer_request_card_test
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
    funding_card.account_number = '5184680430000006'
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
    receiving_card.account_number = '5184680430000014'
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

    transfer = @service.get_transfer(transfer_request_card)
    assert(transfer != nil, 'true')
    assert(transfer.transaction_reference.to_i > 0, 'true')
    assert(transfer.transaction_history.transaction[0] != nil, 'true')
    assert(transfer.transaction_history.transaction[0].response.code.to_i == 00, 'true')
    assert(transfer.transaction_history.transaction[1].response.code.to_i == 00, 'true')
  end

  def test_transfer_request_mapped_test
    trans_ref = transaction_ref_generator

    transfer_request_mapped = TransferRequest.new
    transfer_request_mapped.local_date = '1212'
    transfer_request_mapped.local_time = '161222'
    transfer_request_mapped.transaction_reference = trans_ref

    funding_mapped = FundingMapped.new
    funding_mapped.subscriber_id = 'exampleRubySending@email.com'
    funding_mapped.subscriber_type = 'EMAIL_ADDRESS'
    funding_mapped.subscriber_alias = 'My Debit Card'
    transfer_request_mapped.funding_mapped = funding_mapped

    transfer_request_mapped.funding_ucaf = 'MjBjaGFyYWN0ZXJqdW5rVUNBRjU=1111'
    transfer_request_mapped.funding_mastercard_assigned_id = '123456'

    funding_amount = FundingAmount.new
    funding_amount.value = '15000'
    funding_amount.currency = '840'
    transfer_request_mapped.funding_amount = funding_amount

    transfer_request_mapped.receiver_name = 'Jose Lopez'

    receiver_address = ReceiverAddress.new
    receiver_address.line1 = 'Pueblo Street'
    receiver_address.line2 = 'PO BOX 12'
    receiver_address.city = 'El PASO'
    receiver_address.country_subdivision = 'TX'
    receiver_address.postal_code = '79906'
    receiver_address.country = 'USA'
    transfer_request_mapped.receiver_address = receiver_address

    transfer_request_mapped.receiver_phone = '1800639426'

    receiving_card = ReceivingCard.new
    receiving_card.account_number = '5184680430000014'
    transfer_request_mapped.receiving_card = receiving_card

    receiving_amount = ReceivingAmount.new
    receiving_amount.value = '182206'
    receiving_amount.currency = '484'
    transfer_request_mapped.receiving_amount = receiving_amount

    transfer_request_mapped.channel = 'W'
    transfer_request_mapped.ucaf_support = 'false'
    transfer_request_mapped.ica = '009674'
    transfer_request_mapped.processor_id = '9000000442'
    transfer_request_mapped.routing_and_transit_number = '990442082'

    card_acceptor = CardAcceptor.new
    card_acceptor.name = 'My Local Bank'
    card_acceptor.city = 'Saint Louis'
    card_acceptor.state = 'MO'
    card_acceptor.postal_code = '63101'
    card_acceptor.country = 'USA'
    transfer_request_mapped.card_acceptor = card_acceptor

    transfer_request_mapped.transaction_desc = 'P2P'
    transfer_request_mapped.merchant_id = '123456'

    transfer = @service.get_transfer(transfer_request_mapped)
    assert(transfer != nil, 'true')
    assert(transfer.transaction_reference.to_i > 0, 'true')
    assert(transfer.transaction_history.transaction[0] != nil, 'true')
    assert(transfer.transaction_history.transaction[0].response.code.to_i == 00, 'true')
    assert(transfer.transaction_history.transaction[1].response.code.to_i == 00, 'true')
  end

  def test_payment_request_card
    trans_ref = transaction_ref_generator

    payment_request_card = PaymentRequest.new
    payment_request_card.local_date = '1226'
    payment_request_card.local_time = '125334'
    payment_request_card.transaction_reference = trans_ref
    payment_request_card.sender_name = 'John Doe'

    sender_address = SenderAddress.new
    sender_address.line1 = '123 Main Street'
    sender_address.line2 = '#5A'
    sender_address.city = 'Arlington'
    sender_address.country_subdivision = 'VA'
    sender_address.postal_code = '22207'
    sender_address.country = 'USA'
    payment_request_card.sender_address = sender_address

    receiving_card = ReceivingCard.new
    receiving_card.account_number = '5184680430000014'
    payment_request_card.receiving_card = receiving_card

    receiving_amount = ReceivingAmount.new
    receiving_amount.value = '182206'
    receiving_amount.currency = '484'
    payment_request_card.receiving_amount = receiving_amount

    payment_request_card.ica = '009674'
    payment_request_card.processor_id = '9000000442'
    payment_request_card.routing_and_transit_number = '990442082'

    card_acceptor = CardAcceptor.new
    card_acceptor.name = 'My Local Bank'
    card_acceptor.city = 'Saint Louis'
    card_acceptor.state = 'MO'
    card_acceptor.postal_code = '63101'
    card_acceptor.country = 'USA'
    payment_request_card.card_acceptor = card_acceptor

    payment_request_card.transaction_desc = 'P2P'
    payment_request_card.merchant_id = '123456'

    payment_request = @service.get_transfer(payment_request_card)
    assert(payment_request.request_id != nil, 'true')
    assert(payment_request.request_id.to_i > 0, 'true')
    assert(payment_request.transaction_history.transaction != nil, 'true')
  end

  def test_payment_request_mapped
    trans_ref = transaction_ref_generator

    payment_request_mapped = PaymentRequest.new
    payment_request_mapped.local_date = '1226'
    payment_request_mapped.local_time = '125334'
    payment_request_mapped.transaction_reference = trans_ref
    payment_request_mapped.sender_name = 'John Doe'

    sender_address = SenderAddress.new
    sender_address.line1 = '123 Main Street'
    sender_address.line2 = '#5A'
    sender_address.city = 'Arlington'
    sender_address.country_subdivision = 'VA'
    sender_address.postal_code = '22207'
    sender_address.country = 'USA'
    payment_request_mapped.sender_address = sender_address

    receiving_mapped = ReceivingMapped.new
    receiving_mapped.subscriber_id = 'exampleRubyReceiving@email.com'
    receiving_mapped.subscriber_type = 'EMAIL_ADDRESS'
    receiving_mapped.subscriber_alias = 'My Debit Card'
    payment_request_mapped.receiving_mapped = receiving_mapped

    receiving_amount = ReceivingAmount.new
    receiving_amount.value = '182206'
    receiving_amount.currency = '484'
    payment_request_mapped.receiving_amount = receiving_amount

    payment_request_mapped.ica = '009674'
    payment_request_mapped.processor_id = '9000000442'
    payment_request_mapped.routing_and_transit_number = '990442082'

    card_acceptor = CardAcceptor.new
    card_acceptor.name = 'My Local Bank'
    card_acceptor.city = 'Saint Louis'
    card_acceptor.state = 'MO'
    card_acceptor.postal_code = '63101'
    card_acceptor.country = 'USA'
    payment_request_mapped.card_acceptor = card_acceptor

    payment_request_mapped.transaction_desc = 'P2P'
    payment_request_mapped.merchant_id = '123456'

    payment_request = @service.get_transfer(payment_request_mapped)
    assert(payment_request.request_id != nil, 'true')
    assert(payment_request.request_id.to_i > 0, 'true')
    assert(payment_request.transaction_history.transaction != nil, 'true')
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
