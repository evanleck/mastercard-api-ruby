require_relative '../../../common/connector'
require_relative '../../../common/environment'
require_relative '../../../common/url_util'
require_relative '../../../services/moneysend/domain/card_mapping/DeleteSubscriberId'
require_relative '../../../services/moneysend/domain/card_mapping/DeleteSubscriberIdRequest'

require 'rexml/document'
include REXML
include REXML
include Mastercard::Common
include Mastercard::Services::MoneySend

module Mastercard
  module Services
    module MoneySend

      class DeleteSubscriberIdService < Connector

        PRODUCTION_URL = 'https://api.mastercard.com/moneysend/v2/mapping/subscriber?Format=XML'
        SANDBOX_URL = 'https://sandbox.api.mastercard.com/moneysend/v2/mapping/subscriber?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_delete_subscriber_id(delete_sub_request)
          body = generate_xml(delete_sub_request)
          url = get_url
          doc = Document.new(do_request(url, 'PUT', body))
          generate_return_object(doc)
        end

        def get_url
          url = SANDBOX_URL
          if @environment == PRODUCTION
            url = PRODUCTION_URL
          end
          url
        end

        def generate_xml(delete_sub_request)
          doc = Document.new
          doc << XMLDecl.new(1.0, 'ISO-8859-15')
          root = doc.add_element(generate_inner_xml(delete_sub_request))
          doc.to_s
        end

        def generate_inner_xml(delete_sub_request)
          el = Element.new('DeleteSubscriberIdRequest')
          el.add_element('SubscriberId').add_text(delete_sub_request.subscriber_id)
          el.add_element('SubscriberType').add_text(delete_sub_request.subscriber_type)
          el
        end

        def generate_return_object(xml_body)
          delete_subscriber_id = DeleteSubscriberId.new
          delete_subscriber_id.request_id = xml_body.elements['DeleteSubscriberId/RequestId'].text
          delete_subscriber_id
        end

      end

    end
  end
end
