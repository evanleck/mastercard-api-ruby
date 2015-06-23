require_relative '../../test_helper'
require 'test/unit'

include Mastercard::Common
include Mastercard::Util
include Mastercard::Services::Restaurants

class ReataurantsLocalFavoritesServiceTest < Test::Unit::TestCase

  def setup
    @service = RestaurantsLocalFavoritesService.new(SANDBOX_CONSUMER_KEY, TestUtils.new.get_private_key(SANDBOX), SANDBOX)
  end

  def test_by_numeric_postal_code
    options = RestaurantsLocalFavoritesRequestOptions.new(0, 25)
    options.country = 'USA'
    options.postal_code = 46320
    restaurants = @service.get_restaurants(options)
    assert(restaurants.restaurant != nil, 'true')
    assert(restaurants.restaurant.count > 0, 'true')
  end

end
