require_relative '../../../common/connector'
require_relative '../../../common/environment'
require_relative '../../../common/url_util'
require_relative '../../../common/xml_util'
require_relative '../../../services/moneysend/domain/transfer/TransferReversal'
require_relative '../../../services/moneysend/domain/transfer/TransferReversalRequest'
require_relative '../../../services/moneysend/domain/transfer/TransactionHistory'
require_relative '../../../services/moneysend/domain/transfer/Transaction'
require_relative '../../../services/moneysend/domain/transfer/Response'

require 'rexml/document'
include REXML
include REXML
include Mastercard::Common
include Mastercard::Services::MoneySend

module Mastercard
  module Services
    module MoneySend

      class TransferReversalService < Mastercard::Common::Connector

        PRODUCTION_URL = 'https://api.mastercard.com/moneysend/v2/transferreversal?Format=XML'
        SANDBOX_URL = 'https://sandbox.api.mastercard.com/moneysend/v2/transferreversal?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_transfer_reversal(transfer_reversal_request)
          body = generate_xml(transfer_reversal_request)
          url = get_url
          doc = Document.new(do_request(url, 'POST', body))
          generate_return_object(doc)
        end

        def get_url
          url = SANDBOX_URL
          if @environment == Mastercard::Common::PRODUCTION
            url = PRODUCTION_URL
          end
          url
        end

        def generate_xml(transfer_reversal_request)
          doc = Document.new
          doc << XMLDecl.new(1.0, 'ISO-8859-15')
          root = doc.add_element(generate_inner_xml(transfer_reversal_request))
          doc.to_s
        end

        def generate_inner_xml(transfer_reversal_request)
          el = Element.new('TransferReversalRequest')
          el.add_element('ICA').add_text(transfer_reversal_request.ica)
          el.add_element('TransactionReference').add_text(transfer_reversal_request.transaction_reference)
          el.add_element('ReversalReason').add_text(transfer_reversal_request.reversal_reason)
          el
        end

        def generate_return_object(xml_body)
          xml_util = Mastercard::Common::XMLUtil.new
          transfer_reversal = TransferReversal.new
          xml_transfer_reversal = xml_body.elements['TransferReversal']
          transfer_reversal.request_id = xml_util.verify_not_nil(xml_transfer_reversal.elements['RequestId'])
          transfer_reversal.original_request_id = xml_util.verify_not_nil(xml_transfer_reversal.elements['OriginalRequestId'])
          transfer_reversal.transaction_reference = xml_util.verify_not_nil(xml_transfer_reversal.elements['TransactionReference'])

          transaction_history = TransactionHistory.new
          xml_transaction_history = xml_transfer_reversal.elements['TransactionHistory']

          transaction = Transaction.new
          xml_transaction = xml_transaction_history.elements['Transaction']
          transaction.type = xml_util.verify_not_nil(xml_transaction.elements['Type'])
          transaction.system_trace_audit_number = xml_util.verify_not_nil(xml_transaction.elements['SystemTraceAuditNumber'])
          transaction.network_reference_number = xml_util.verify_not_nil(xml_transaction.elements['NetworkReferenceNumber'])
          transaction.settlement_date = xml_util.verify_not_nil(xml_transaction.elements['SettlementDate'])

          response = Response.new
          xml_response = xml_transaction.elements['Response']
          response.code = xml_util.verify_not_nil(xml_response.elements['Code'])
          response.description = xml_util.verify_not_nil(xml_response.elements['Description'])
          transaction.response = response

          transaction.submit_date_time = xml_util.verify_not_nil(xml_transaction.elements['SubmitDateTime'])

          transaction_history.transaction = transaction
          transfer_reversal.transaction_history = transaction_history
          transfer_reversal
        end

      end

    end
  end
end
