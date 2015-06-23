require_relative '../../test_helper'
require 'test/unit'

include Mastercard::Common
include Mastercard::Util
include Mastercard::Services::BillPayment

class RoutingValidationServiceTest < Test::Unit::TestCase

  def setup
    @service = RoutingValidationService.new(SANDBOX_CONSUMER_KEY, TestUtils.new.get_private_key(SANDBOX), SANDBOX)
  end

  #####
  # The test data used was taken from the Bill Payment Routing Validation API Sandbox page.
  # The tests are checking the ResponseString coming back.
  # The value of the response strings are not listed in the documentation and if changed will break the tests.
  #####

  def test_routing_validation_service_success
    bill_pay_account_validation_request = BillPayAccountValidation.new
    bill_pay_account_validation_request.rpps_id = '99887761'
    bill_pay_account_validation_request.biller_id = '9998887771'
    bill_pay_account_validation_request.account_number = '1234567890'
    bill_pay_account_validation_request.transaction_amount = '250.00'
    bill_pay_account_validation_response = @service.get_bill_pay_account_validation(bill_pay_account_validation_request)
    assert(bill_pay_account_validation_response.response_string == "Successful", 'true')
  end

  def test_routing_validation_service_invalid_rppsid
    bill_pay_account_validation_request = BillPayAccountValidation.new
    bill_pay_account_validation_request.rpps_id = '00000000'
    bill_pay_account_validation_request.biller_id = '9998887771'
    bill_pay_account_validation_request.account_number = '1234567890'
    bill_pay_account_validation_request.transaction_amount = '250.00'
    bill_pay_account_validation_response = @service.get_bill_pay_account_validation(bill_pay_account_validation_request)
    assert(bill_pay_account_validation_response.response_string == 'Invalid RPPSID', 'true')
  end

  def test_routing_validation_service_inactive_rppisd
    bill_pay_account_validation_request = BillPayAccountValidation.new
    bill_pay_account_validation_request.rpps_id = '99887760'
    bill_pay_account_validation_request.biller_id = '9998887771'
    bill_pay_account_validation_request.account_number = '1234567890'
    bill_pay_account_validation_request.transaction_amount = '250.00'
    bill_pay_account_validation_response = @service.get_bill_pay_account_validation(bill_pay_account_validation_request)
    assert(bill_pay_account_validation_response.response_string == 'RPPSID is not active', 'true')
  end

  def test_routing_validation_service_invalid_billerid
    bill_pay_account_validation_request = BillPayAccountValidation.new
    bill_pay_account_validation_request.rpps_id = '99887761'
    bill_pay_account_validation_request.biller_id = '0000000000'
    bill_pay_account_validation_request.account_number = '1234567890'
    bill_pay_account_validation_request.transaction_amount = '250.00'
    bill_pay_account_validation_response = @service.get_bill_pay_account_validation(bill_pay_account_validation_request)
    assert(bill_pay_account_validation_response.response_string == 'Invalid BillerID', 'true')
  end

  def test_routing_validation_service_inactive_billerid
    bill_pay_account_validation_request = BillPayAccountValidation.new
    bill_pay_account_validation_request.rpps_id = '99887761'
    bill_pay_account_validation_request.biller_id = '9998887772'
    bill_pay_account_validation_request.account_number = '1234567890'
    bill_pay_account_validation_request.transaction_amount = '250.00'
    bill_pay_account_validation_response = @service.get_bill_pay_account_validation(bill_pay_account_validation_request)
    assert(bill_pay_account_validation_response.response_string == 'BillerID is not active', 'true')
  end

  def test_routing_validation_service_exceeds_trans_amount
    bill_pay_account_validation_request = BillPayAccountValidation.new
    bill_pay_account_validation_request.rpps_id = '99887761'
    bill_pay_account_validation_request.biller_id = '9998887771'
    bill_pay_account_validation_request.account_number = '1234567890'
    bill_pay_account_validation_request.transaction_amount = '5000.00'
    bill_pay_account_validation_response = @service.get_bill_pay_account_validation(bill_pay_account_validation_request)
    assert(bill_pay_account_validation_response.response_string == 'Transaction Amount exceeds BillerID maximum', 'true')
  end

end
