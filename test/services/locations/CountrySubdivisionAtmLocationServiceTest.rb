require_relative '../../test_helper'
require 'test/unit'

include Mastercard::Common
include Mastercard::Util
include Mastercard::Services::Locations

class CountrySubdivisionAtmLocationServiceTest < Test::Unit::TestCase

  def setup
    @service = CountrySubdivisionAtmLocationService.new(SANDBOX_CONSUMER_KEY, TestUtils.new.get_private_key(SANDBOX), SANDBOX)
  end

  def test_service
    options = CountrySubdivisionAtmLocationRequestOptions.new
    options.country = 'USA'
    country_subdivisions = @service.get_country_subdivisions(options)
    assert(country_subdivisions.country_subdivision.size > 0, 'true')
    assert(country_subdivisions != nil, 'true')
  end

end
