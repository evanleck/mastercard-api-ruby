require_relative '../../common/connector'
require_relative '../../common/environment'
require_relative '../../common/url_util'
require_relative '../../common/xml_util'
require_relative '../../services/bill_payment/domain/BillPayAccountValidation'

require 'rexml/document'
include REXML
include Mastercard::Common
include Mastercard::Services::BillPayment

module Mastercard
  module Services
    module BillPayment

      class RoutingValidationService < Connector

        PRODUCTION_URL = 'https://api.mastercard.com/billpayAPI/v1/isRoutingValid?Format=XML'
        SANDBOX_URL = 'https://sandbox.api.mastercard.com/billpayAPI/v1/isRoutingValid?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_bill_pay_account_validation(routing_validation)
          body = generate_xml(routing_validation)
          url = get_url
          doc = Document.new(do_request(url, 'POST', body))
          generate_return_object(doc)
        end

        def generate_xml(routing_validation)
          doc = Document.new
          doc << XMLDecl.new(1.0, 'ISO-8859-15')
          root = doc.add_element(generate_inner_xml(routing_validation))
          doc.to_s
        end

        def generate_inner_xml(routing_validation)
          el = Element.new('BillPayAccountValidation')
          el.add_element('RppsId').add_text(routing_validation.rpps_id)
          el.add_element('BillerId').add_text(routing_validation.biller_id)
          el.add_element('AccountNumber').add_text(routing_validation.account_number)
          el.add_element('TransactionAmount').add_text(routing_validation.transaction_amount)
          el.add_element('CustomerIdentifier1').add_text(routing_validation.customer_identifier1)
          el.add_element('CustomerIdentifier2').add_text(routing_validation.customer_identifier2)
          el.add_element('CustomerIdentifier3').add_text(routing_validation.customer_identifier3)
          el.add_element('CustomerIdentifier4').add_text(routing_validation.customer_identifier4)
          el.add_element('ResponseString').add_text(routing_validation.response_string)
          el
        end

        def get_url
          url = SANDBOX_URL.dup
          if @environment == PRODUCTION
            url = PRODUCTION_URL.dup
          end
          url
        end

        def generate_return_object(xml_body)
          xml_util = XMLUtil.new

          bill_pay_account_validation = BillPayAccountValidation.new
          xml_bill_pay_account_validation = xml_body.elements['BillPayAccountValidation']
          bill_pay_account_validation.rpps_id = xml_util.verify_not_nil(xml_bill_pay_account_validation.elements['RppsId'])
          bill_pay_account_validation.biller_id = xml_util.verify_not_nil(xml_bill_pay_account_validation.elements['BillerId'])
          bill_pay_account_validation.account_number = xml_util.verify_not_nil(xml_bill_pay_account_validation.elements['AccountNumber'])
          bill_pay_account_validation.transaction_amount = xml_util.verify_not_nil(xml_bill_pay_account_validation.elements['TransactionAmount'])
          bill_pay_account_validation.customer_identifier1 = xml_util.verify_not_nil(xml_bill_pay_account_validation.elements['CustomerIdentifier1'])
          bill_pay_account_validation.customer_identifier2 = xml_util.verify_not_nil(xml_bill_pay_account_validation.elements['CustomerIdentifier2'])
          bill_pay_account_validation.customer_identifier3 = xml_util.verify_not_nil(xml_bill_pay_account_validation.elements['CustomerIdentifier3'])
          bill_pay_account_validation.customer_identifier4 = xml_util.verify_not_nil(xml_bill_pay_account_validation.elements['CustomerIdentifier4'])
          bill_pay_account_validation.response_string = xml_util.verify_not_nil(xml_bill_pay_account_validation.elements['ResponseString'])
          bill_pay_account_validation
        end

      end
    end
  end
end