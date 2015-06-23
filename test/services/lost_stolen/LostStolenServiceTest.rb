require_relative '../../test_helper'
require 'test/unit'

include Mastercard::Util
include Mastercard::Common
include Mastercard::Services::LostStolen

class LostStolenServiceTest < Test::Unit::TestCase

  def setup
      @service = LostStolenService.new(SANDBOX_CONSUMER_KEY, TestUtils.new.get_private_key(SANDBOX), SANDBOX)
  end

  def test_stolen
    account = @service.get_account('5343434343434343')
    assert('true' == account.status)
    assert('true' == account.listed)
    assert('S' == account.reason_code)
    assert('STOLEN' == account.reason)
  end


  def test_fraud
    account = @service.get_account('5105105105105100')
    assert('true' == account.status)
    assert('true' == account.listed)
    assert('F' == account.reason_code)
    assert('FRAUD' == account.reason)
  end

  def test_lost
    account = @service.get_account('5222222222222200')
    assert('true' == account.status)
    assert('true' == account.listed)
    assert('L' == account.reason_code)
    assert('LOST' == account.reason)
  end

  def test_capture_card
    account = @service.get_account('5305305305305300')
    assert('true' == account.status)
    assert('true' == account.listed)
    assert('P' == account.reason_code)
    assert('CAPTURE CARD' == account.reason)
  end

  def test_unauthorized_use
    account = @service.get_account('6011111111111117')
    assert('true' == account.status)
    assert('true' == account.listed)
    assert('U' == account.reason_code)
    assert('UNAUTHORIZED USE' == account.reason)
  end

  def test_counterfeit
    account = @service.get_account('4444333322221111')
    assert('true' == account.status)
    assert('true' == account.listed)
    assert('X' == account.reason_code)
    assert('COUNTERFEIT' == account.reason)
  end

  def test_not_listed
    account = @service.get_account('343434343434343')
    assert('true' == account.status)
    assert('false' == account.listed)
    assert(nil == account.reason_code)
    assert(nil == account.reason)
  end

end
