require_relative '../../test_helper'
require 'test/unit'

include Mastercard::Common
include Mastercard::Util
include Mastercard::Services::MoneySend

class PanEligibilityServiceTest < Test::Unit::TestCase

  def setup
    @service = PanEligibilityService.new(SANDBOX_CONSUMER_KEY, TestUtils.new.get_private_key(SANDBOX), SANDBOX)
  end

  def test_pan_eligibility_service_eligible
    pan_eligibility_request = PanEligibilityRequest.new
    pan_eligibility_request.sending_account_number = '5184680430000006'
    pan_eligibility_request.receiving_account_number = '5184680430000006'
    pan_eligibility = @service.get_pan_eligibility(pan_eligibility_request)
    assert(pan_eligibility != nil)
    assert(pan_eligibility.sending_eligibility.eligible == 'true')
    assert(pan_eligibility.receiving_eligibility.eligible == 'true')
  end

  def test_pan_eligibility_service_sending_not_eligible
    pan_eligibility_request = PanEligibilityRequest.new
    pan_eligibility_request.sending_account_number = '5184680990000024'
    pan_eligibility = @service.get_pan_eligibility(pan_eligibility_request)
    assert(pan_eligibility != nil)
    assert(pan_eligibility.sending_eligibility.eligible == 'false')
  end

  def test_pan_eligibility_service_receiving_not_eligible
    pan_eligibility_request = PanEligibilityRequest.new
    pan_eligibility_request.receiving_account_number = '5184680060000201'
    pan_eligibility = @service.get_pan_eligibility(pan_eligibility_request)
    assert(pan_eligibility != nil)
    assert(pan_eligibility.receiving_eligibility.eligible == 'false')
  end

end
