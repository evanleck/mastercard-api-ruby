require_relative '../../test_helper'
require 'test/unit'

include Mastercard::Common
include Mastercard::Util
include Mastercard::Services::Locations

class MerchantLocationServiceTest < Test::Unit::TestCase

  def setup
    @service = MerchantLocationService.new(PRODUCTION_CONSUMER_KEY, TestUtils.new.get_private_key(PRODUCTION), PRODUCTION)
  end

  def test_merchant_location_service_repower
    options = MerchantLocationRequestOptions.new(Details::TOPUP_REPOWER, 0, 25)
    country = Country.new
    country.name = 'USA'
    options.country = country
    options.postal_code = 22122
    merchants = @service.get_merchants(options)
    assert(merchants.merchant.count > 0, 'true')
    assert(merchants.merchant[0].id.to_i > 0, 'true')
  end

  # At the time of the creation of this SDK, PPTC was not returning
  # valid results. Passing of this test implies that PPTC has begun to return
  # valid results and that no SDK changes are needed.

  # def test_merchant_location_service_prepaid_travel_card_fail
  #   options = MerchantLocationRequestOptions.new(Details::PRODUCTS_PREPAID_TRAVEL_CARD, 0, 25)
  #   country = Country.new
  #   country.name = 'USA'
  #   options.country = country
  #   options.postal_code = 20006
  #   merchants = @service.get_merchants(options)
  #   assert(merchants.merchant.count > 0, 'true')
  # end

  # At the time of the creation of this SDK, PPTC was not returning valid results
  # Comment out this unit test once it does.

  def test_merchant_location_service_prepaid_travel_card_pass
    options = MerchantLocationRequestOptions.new(Details::PRODUCTS_PREPAID_TRAVEL_CARD, 0, 25)
    country = Country.new
    country.name = 'USA'
    options.country = country
    options.postal_code = 20006
    merchants = @service.get_merchants(options)
    assert(merchants.merchant.count == 0, 'true')
  end

  def test_merchant_location_service_offers
    options = MerchantLocationRequestOptions.new(Details::OFFERS_EASYSAVINGS, 0, 25)
    country = Country.new
    country.name = 'USA'
    options.country = country
    options.postal_code = 22122
    merchants = @service.get_merchants(options)
    assert(merchants.merchant.count > 0, 'true')
    assert(merchants.merchant[0].id.to_i > 0, 'true')
  end

  def test_merchant_location_service_paypass
    options = MerchantLocationRequestOptions.new(Details::ACCEPTANCE_PAYPASS, 0, 25)
    country = Country.new
    country.name = 'USA'
    options.country = country
    options.postal_code = 07032
    merchants = @service.get_merchants(options)
    assert(merchants.merchant.count > 0, 'true')
    assert(merchants.merchant[0].id.to_i > 0, 'true')
  end

  def test_merchant_location_service_cashback
    options = MerchantLocationRequestOptions.new(Details::FEATURES_CASHBACK, 0, 25)
    country = Country.new
    country.name = 'USA'
    options.country = country
    options.postal_code = 46323
    merchants = @service.get_merchants(options)
    assert(merchants.merchant.count > 0, 'true')
    assert(merchants.merchant[0].id.to_i > 0, 'true')
  end

end
