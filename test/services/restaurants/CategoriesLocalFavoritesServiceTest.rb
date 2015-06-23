require_relative '../../test_helper'
require 'test/unit'

include Mastercard::Common
include Mastercard::Util
include Mastercard::Services::Restaurants

class CategoriesLocalFavoritesServiceTest < Test::Unit::TestCase

  def setup
    @service = CategoriesLocalFavoritesService.new(SANDBOX_CONSUMER_KEY, TestUtils.new.get_private_key(SANDBOX), SANDBOX)
  end

  def test_local_favorites_categories
    categories = @service.get_categories
    assert(categories.category.size > 0, 'true')
    assert(categories != nil, 'true')
  end

end
