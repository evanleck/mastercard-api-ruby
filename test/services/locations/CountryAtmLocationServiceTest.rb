require_relative '../../test_helper'
require 'test/unit'

include Mastercard::Common
include Mastercard::Util
include Mastercard::Services::Locations

class CountryAtmLocationServiceTest < Test::Unit::TestCase

  def setup
    @service = CountryAtmLocationService.new(SANDBOX_CONSUMER_KEY, TestUtils.new.get_private_key(SANDBOX), SANDBOX)
  end

  def test_country_merchant_location_service
    countries = @service.get_countries
    assert(countries.country.size > 0, 'true')
    assert(countries != nil, 'true')
  end

end
