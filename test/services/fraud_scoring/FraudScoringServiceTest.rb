require_relative '../../test_helper'
require 'test/unit'
require 'open-uri'

include Mastercard::Common
include Mastercard::Util
include Mastercard::Services::FraudScoring
include Mastercard::Test::FraudScoring

class FraudScoringServiceTest < Test::Unit::TestCase

  def setup
    @service = FraudScoringService.new(SANDBOX_CONSUMER_KEY, TestUtils.new.get_private_key(SANDBOX), SANDBOX)
    @score_lookup_request = ScoreLookupRequest.new
    @transaction_detail = TransactionDetail.new
    @transaction_detail.customer_identifier = '1996'
    @transaction_detail.merchant_identifier = '123'
    @transaction_detail.account_number = '5555555555555555555'
    @transaction_detail.account_prefix = '555555'
    @transaction_detail.account_suffix = '5555'
    @transaction_detail.transaction_date = '1231'
    @transaction_detail.transaction_time = '035959'
    @transaction_detail.bank_net_reference_number = 'abcABC123'
    @transaction_detail.stan = '123456'
  end

  def test_low_fraud_scoring_single_transaction_match
    @transaction_detail.transaction_amount = '62500'
    @score_lookup_request.transaction_detail = @transaction_detail
    score_lookup = @service.get_score_lookup(@score_lookup_request)
    assert(score_lookup.score_response.match_indicator == MatchIndicatorStatus::SINGLE_TRANSACTION_MATCH, 'true')
  end

  def test_mid_fraud_scoring_single_transaction_match
    @transaction_detail.transaction_amount = '10001'
    @score_lookup_request.transaction_detail = @transaction_detail
    score_lookup = @service.get_score_lookup(@score_lookup_request)
    assert(score_lookup.score_response.match_indicator == MatchIndicatorStatus::MULTIPLE_TRANS_IDENTICAL_CARD_MATCH, 'true')
  end

  def test_high_fraud_scoring_single_transaction_match
    @transaction_detail.transaction_amount = '20001'
    @score_lookup_request.transaction_detail = @transaction_detail
    score_lookup = @service.get_score_lookup(@score_lookup_request)
    assert(score_lookup.score_response.match_indicator == MatchIndicatorStatus::MULTIPLE_TRANS_DIFFERING_CARDS_MATCH, 'true')
  end

  def test_no_match_found
    @transaction_detail.transaction_amount = '30001'
    @score_lookup_request.transaction_detail = @transaction_detail
    score_lookup = @service.get_score_lookup(@score_lookup_request)
    assert(score_lookup.score_response.match_indicator == MatchIndicatorStatus::NO_MATCH_FOUND, 'true')
  end


  ######################
  # Expected Exception #
  ######################

  def test_system_error
    begin
      @transaction_detail.transaction_amount = '50001'
      @score_lookup_request.transaction_detail = @transaction_detail
      score_lookup = @service.get_score_lookup(@score_lookup_request)
    rescue Exception => e
      if assert e.message.include? '404'
        puts 'System Error Test Successful'
      else
        raise e
      end
    end
  end

end
