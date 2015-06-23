require_relative '../../test_helper'
require 'test/unit'

include Mastercard::Common
include Mastercard::Util
include Mastercard::Services::Locations

class AtmLocationServiceTest < Test::Unit::TestCase

  def setup
    @service = AtmLocationService.new(PRODUCTION_CONSUMER_KEY, TestUtils.new.get_private_key(PRODUCTION), PRODUCTION)
  end

  def test_by_numeric_postal_code
    options = AtmLocationRequestOptions.new(0, 25)
    options.country = 'USA'
    options.postal_code = 46320
    atms = @service.get_atms(options)
    assert(atms.atm != nil, 'true')
    assert(atms.atm.count > 0, 'true')
  end

  def test_by_foreign_postal_code
    options = AtmLocationRequestOptions.new(0, 25)
    options.country = 'SGP'
    options.postal_code = '068897'
    atms = @service.get_atms(options)
    assert(atms.atm != nil, 'true')
    assert(atms.atm.count > 0, 'true')
  end

  def test_by_latitude_longitude
    options = AtmLocationRequestOptions.new(0, 25)
    options.latitude =  1.2833
    options.longitude = 103.8499
    options.radius = 5
    options.distance_unit = AtmLocationRequestOptions::KILOMETER
    atms = @service.get_atms(options)
    assert(atms.atm != nil, 'true')
    assert(atms.atm.count > 0, 'true')
  end

  def test_by_address
    options = AtmLocationRequestOptions.new(0, 25)
    options.address_line1 = 'BLK 1 ROCHOR ROAD UNIT 01-640 ROCHOR ROAD'
    options.country = 'SGP'
    atms = @service.get_atms(options)
    assert(atms.atm != nil, 'true')
    assert(atms.atm.count > 0, 'true')
  end

  def test_by_city
    options = AtmLocationRequestOptions.new(0, 25)
    options.city = 'CHICAGO'
    options.country = 'USA'
    atms = @service.get_atms(options)
    assert(atms.atm != nil, 'true')
    assert(atms.atm.count > 0, 'true')
  end

  def test_by_country_subdivision
    options = AtmLocationRequestOptions.new(0, 25)
    options.country = 'USA'
    options.country_subdivision = 'IL'
    atms = @service.get_atms(options)
    assert(atms.atm != nil, 'true')
    assert(atms.atm.count > 0, 'true')
  end

  def test_by_support_emv
    options = AtmLocationRequestOptions.new(0, 25)
    options.support_emv = AtmLocationRequestOptions::SUPPORT_EMV_YES
    options.latitude = 1.2833
    options.longitude = 103.8499
    atms = @service.get_atms(options)
    assert(atms.atm != nil, 'true')
    assert(atms.atm.count > 0, 'true')
  end

end
