require_relative '../../test_helper'
require 'test/unit'

include Mastercard::Util
include Mastercard::Services::Repower
include Mastercard::Services::RepowerReversal
include Mastercard::Common

class RepowerServiceTest < Test::Unit::TestCase

  def setup
    @service = RepowerService.new(SANDBOX_CONSUMER_KEY, TestUtils.new.get_private_key(SANDBOX), SANDBOX)
    @serviceReversal = RepowerReversalService.new(SANDBOX_CONSUMER_KEY, TestUtils.new.get_private_key(SANDBOX), SANDBOX)
    @repower_request = RepowerRequest.new
    @repower_reversal_request = RepowerReversalRequest.new
  end

  def testRepowerService
    trans_ref = transaction_ref_generator

    @repower_request.transaction_reference = trans_ref
    @repower_request.card_number = '5184680430000014'

    transaction_amount = TransactionAmount.new
    transaction_amount.value = '000000030000'
    transaction_amount.currency = '840'
    @repower_request.transaction_amount = transaction_amount

    @repower_request.local_date = '1230'
    @repower_request.local_time = '092435'
    @repower_request.channel = 'W'
    @repower_request.ica = '009674'
    @repower_request.processor_id = '9000000442'
    @repower_request.routing_and_transit_number = '990442082'
    @repower_request.merchant_type = '6532'

    card_acceptor = CardAcceptor.new
    card_acceptor.name = 'Prepaid Load Store'
    card_acceptor.city = 'St Charles'
    card_acceptor.state = 'MO'
    card_acceptor.postal_code = '63301'
    card_acceptor.country = 'USA'
    @repower_request.card_acceptor = card_acceptor

    repower = @service.get_repower(@repower_request)
    assert(repower.request_id != nil, 'true')
    assert(repower.request_id.to_i > 0, 'true')
    assert(repower.transaction_history.transaction.response.code.to_i == 00, 'true')

    @repower_reversal_request.reversal_reason = 'UNIT TEST'
    @repower_reversal_request.transaction_reference = trans_ref
    @repower_reversal_request.ica = '009674'

    repower_reversal = @serviceReversal.get_repower_reversal(@repower_reversal_request)
    assert(repower_reversal.request_id != nil, 'true')
    assert(repower_reversal.transaction_history.transaction.response.code.to_i == 00, 'true')
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
