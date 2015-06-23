require_relative '../../test_helper'
require 'test/unit'

include Mastercard::Common
include Mastercard::Util
include Mastercard::Services::MoneySend

class CardMappingServiceTest < Test::Unit::TestCase

  def setup
    @service = CardMappingService.new(SANDBOX_CONSUMER_KEY, TestUtils.new.get_private_key(SANDBOX), SANDBOX)
  end

  def test_create_mapping
    create_mapping_request = CreateMappingRequest.new
    create_mapping_request.subscriber_id = 'exampleRubyReceiving20@email.com'
    create_mapping_request.subscriber_type = 'EMAIL_ADDRESS'
    create_mapping_request.account_usage = 'RECEIVING'
    create_mapping_request.account_number = '5184680430000014'
    create_mapping_request.default_indicator = 'T'
    create_mapping_request.expiry_date = '201409'
    create_mapping_request.alias = 'My Debit Card'
    create_mapping_request.ica = '009674'

    address = Address.new
    address.line1 = '123 Main Street'
    address.line2 = '#5A'
    address.city = 'OFallon'
    address.country_subdivision = 'MO'
    address.country = 'USA'
    address.postal_code = '63368'

    cardholder_full_name = CardholderFullName.new
    cardholder_full_name.cardholder_first_name = 'John'
    cardholder_full_name.cardholder_middle_name = 'Q'
    cardholder_full_name.cardholder_last_name = 'Public'

    create_mapping_request.address = address
    create_mapping_request.cardholder_full_name = cardholder_full_name
    create_mapping_request.date_of_birth = '19460102'

    create_mapping = @service.get_create_mapping(create_mapping_request)
    assert(create_mapping.request_id != nil && create_mapping.request_id.length > 0, 'true')
    assert(create_mapping.mapping.mapping_id != nil && create_mapping.mapping.mapping_id.to_i > 0, 'true')
  end

  def test_inquire_mapping_one_mapping
    inquire_mapping_request = InquireMappingRequest.new
    inquire_mapping_request.subscriber_id = 'exampleRubySending@email.com'
    inquire_mapping_request.subscriber_type = 'EMAIL_ADDRESS'
    inquire_mapping_request.account_usage = 'SENDING'
    inquire_mapping_request.alias = 'My Debit Card'
    inquire_mapping_request.data_response_flag = '3'
    inquire_mapping = @service.get_inquire_mapping(inquire_mapping_request)
    assert(inquire_mapping != nil, 'true')
    assert(inquire_mapping.request_id != nil && inquire_mapping.request_id.to_i > 0, 'true')
    assert(inquire_mapping.mappings.mapping[0].mapping_id != nil && inquire_mapping.mappings.mapping[0].mapping_id.to_i > 0, 'true')
  end

  def test_inquire_mapping_mappings
    inquire_mapping_request = InquireMappingRequest.new
    inquire_mapping_request.subscriber_id = 'exampleRubyReceiving@email.com'
    inquire_mapping_request.subscriber_type = 'EMAIL_ADDRESS'
    inquire_mapping = @service.get_inquire_mapping(inquire_mapping_request)
    assert(inquire_mapping != nil, 'true')
    assert(inquire_mapping.request_id != nil && inquire_mapping.request_id.to_i > 0, 'true')
    assert(inquire_mapping.mappings.mapping[0].mapping_id != nil && inquire_mapping.mappings.mapping[0].mapping_id.to_i > 0, 'true')
  end

  def test_update_mapping
    inquire_mapping_request = InquireMappingRequest.new
    inquire_mapping_request.subscriber_id = 'exampleRubyReceiving@email.com'
    inquire_mapping_request.subscriber_type = 'EMAIL_ADDRESS'
    inquire_mapping = @service.get_inquire_mapping(inquire_mapping_request)

    options = UpdateMappingRequestOptions.new
    options.mapping_id = inquire_mapping.mappings.mapping[0].mapping_id

    update_mapping_request = UpdateMappingRequest.new
    update_mapping_request.account_usage = 'RECEIVING'
    update_mapping_request.account_number = '5184680430000014'
    update_mapping_request.default_indicator = 'T'
    update_mapping_request.expiry_date = '201409'
    update_mapping_request.alias = 'Updated Debit Card'

    address = Address.new
    address.line1 = '123 Main Street'
    address.line2 = '#5A'
    address.city = 'OFallon'
    address.country_subdivision = 'MO'
    address.country = 'USA'
    address.postal_code = '63368'

    cardholder_full_name = CardholderFullName.new
    cardholder_full_name.cardholder_first_name = 'John'
    cardholder_full_name.cardholder_middle_name = 'X'
    cardholder_full_name.cardholder_last_name = 'Private'

    update_mapping_request.address = address
    update_mapping_request.cardholder_full_name = cardholder_full_name
    update_mapping_request.date_of_birth = '19460102'

    update_mapping = @service.get_update_mapping(update_mapping_request, options)
    assert(update_mapping.request_id != nil && update_mapping.request_id.length > 0, 'true')
    assert(update_mapping.mapping.mapping_id != nil && update_mapping.mapping.mapping_id.to_i > 0, 'true')
  end

  def test_delete_mapping
    inquire_mapping_request = InquireMappingRequest.new
    inquire_mapping_request.subscriber_id = 'exampleRubySending@email.com'
    inquire_mapping_request.subscriber_type = 'EMAIL_ADDRESS'
    inquire_mapping = @service.get_inquire_mapping(inquire_mapping_request)
    assert(inquire_mapping.mappings.mapping[0].mapping_id != nil && inquire_mapping.mappings.mapping[0].mapping_id.to_i > 0, 'true')

    options = DeleteMappingRequestOptions.new
    options.mapping_id = inquire_mapping.mappings.mapping[0].mapping_id

    delete_mapping = @service.get_delete_mapping(options)
    assert(delete_mapping != nil, 'true')
    assert(delete_mapping.request_id.to_i > 0, 'true')
    assert(delete_mapping.mapping.mapping_id.to_i > 0, 'true')
  end

end
