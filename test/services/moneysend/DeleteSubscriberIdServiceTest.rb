require_relative '../../test_helper'
require 'test/unit'

include Mastercard::Common
include Mastercard::Util
include Mastercard::Services::MoneySend

class DeleteSubscriberIdServiceTest < Test::Unit::TestCase

  def setup
    @service = DeleteSubscriberIdService.new(SANDBOX_CONSUMER_KEY, TestUtils.new.get_private_key(SANDBOX), SANDBOX)
  end

  def test_delete_subscriber_id_service
    delete_subscriber_id_request = DeleteSubscriberIdRequest.new
    delete_subscriber_id_request.subscriber_id = 'exampleRubyReceiving2@email.com'
    delete_subscriber_id_request.subscriber_type = 'EMAIL_ADDRESS'
    delete_subscriber_id = @service.get_delete_subscriber_id(delete_subscriber_id_request)
    assert(delete_subscriber_id.request_id != nil)
    assert(delete_subscriber_id.request_id.to_i > 0)
  end

end
