require_relative '../../test_helper'
require 'test/unit'

include Mastercard::Common
include Mastercard::Util
include Mastercard::Services::Locations

class CountrySubdivisionMerchantLocationServiceTest < Test::Unit::TestCase

  def setup
    @service = CountrySubdivisionMerchantLocationService.new(SANDBOX_CONSUMER_KEY, TestUtils.new.get_private_key(SANDBOX), SANDBOX)
  end

  def test_country_subdivision_service_with_paypass
    options = CountrySubdivisionMerchantLocationRequestOptions.new(Details::ACCEPTANCE_PAYPASS, 'USA')
    country_subdivisions = @service.get_country_subdivisions(options)
    assert(country_subdivisions.country_subdivision.size > 0, 'true')
    assert(country_subdivisions != nil, 'true')
  end

  def test_country_subdivision_service_with_offers
    options = CountrySubdivisionMerchantLocationRequestOptions.new(Details::OFFERS_EASYSAVINGS, 'USA')
    country_subdivisions = @service.get_country_subdivisions(options)
    assert(country_subdivisions.country_subdivision.size > 0, 'true')
    assert(country_subdivisions != nil, 'true')
  end

  def test_country_subdivision_service_with_prepaid_travel
    options = CountrySubdivisionMerchantLocationRequestOptions.new(Details::PRODUCTS_PREPAID_TRAVEL_CARD, 'USA')
    country_subdivisions = @service.get_country_subdivisions(options)
    assert(country_subdivisions.country_subdivision.size > 0, 'true')
    assert(country_subdivisions != nil, 'true')
  end

  def test_country_subdivision_service_with_repower
    options = CountrySubdivisionMerchantLocationRequestOptions.new(Details::TOPUP_REPOWER, 'USA')
    country_subdivisions = @service.get_country_subdivisions(options)
    assert(country_subdivisions.country_subdivision.size > 0, 'true')
    assert(country_subdivisions != nil, 'true')
  end

end
