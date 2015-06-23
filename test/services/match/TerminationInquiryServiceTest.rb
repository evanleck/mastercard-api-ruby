require_relative '../../test_helper'
require 'test/unit'

include Mastercard::Util
include Mastercard::Services::Match

class TerminationInquiryServiceTest < Test::Unit::TestCase

  def setup
    @service = TerminationInquiryService.new(SANDBOX_CONSUMER_KEY, TestUtils.new.get_private_key(SANDBOX), SANDBOX)
  end

  def test_termination_inquiry
    principal_address = AddressType.new
    principal_address.line1 = '93-52 243 STREET'
    principal_address.city = 'BELLEROSE'
    principal_address.country_subdivision = 'NY'
    principal_address.country = 'USA'
    principal_address.postal_code = '55555-5555'
    principal = PrincipalType.new
    principal.first_name = 'PATRICIA'
    principal.last_name = 'CLARKE'
    principal.address = principal_address
    principal_drivers_license = DriversLicenseType.new
    principal_drivers_license.number = ''
    principal_drivers_license.country = ''
    principal_drivers_license.country_subdivision = ''
    merchant_address = AddressType.new
    merchant_address.line1 = '20 EAST MAIN ST'
    merchant_address.line2 = 'EAST ISLIP           NY'
    merchant_address.city = 'EAST ISLIP'
    merchant_address.country_subdivision = 'NY'
    merchant_address.country = 'USA'
    merchant_address.postal_code = '55555'
    merchant = MerchantType.new
    merchant.address = merchant_address
    merchant.country_subdivision_tax_id = '205545287'
    merchant.national_tax_id = '2891327625'
    merchant.name = 'TERMINATED MERCHANT 2'
    merchant.doing_business_as_name = 'DOING BUSINESS AS TERMINATED MERCHANT 2'
    merchant.phone_number = '5555555555'
    merchant.principal = principal
    request = TerminationInquiryRequest.new
    request.acquirer_id = '1996'
    request.merchant = merchant
    request.transaction_reference_number = '12345'
    response = @service.get_termination_inquiry(request, TerminationInquiryRequestOptions.new(0, 10))
    assert(response.transaction_reference_number != nil, 'true')
    assert(response.terminated_merchant != nil, 'true')
  end

end
