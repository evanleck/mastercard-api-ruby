require_relative '../../../common/connector'
require_relative '../../../common/environment'
require_relative '../../../common/url_util'
require_relative '../../../services/repower/repower_reversal/domain/RepowerReversal'
require_relative '../../../services/repower/repower_reversal/domain/RepowerReversalRequest'

require 'rexml/document'
include REXML

module Mastercard
  module Services
    module RepowerReversal

      class RepowerReversalService < Connector

        PRODUCTION_URL = 'https://api.mastercard.com/repower/v1/repowerreversal?Format=XML'
        SANDBOX_URL = 'https://sandbox.api.mastercard.com/repower/v1/repowerreversal?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_repower_reversal(repower_reversal)
          body = generate_xml(repower_reversal)
          url = get_url
          doc = Document.new(do_request(url, 'POST', body))
          generate_return_object(doc)
        end

        def generate_xml(repower_reversal)
          doc = Document.new
          doc << XMLDecl.new(1.0, 'ISO-8859-15')
          root = doc.add_element(generate_inner_xml(repower_reversal))
          doc.to_s
        end

        def generate_inner_xml(repower_reversal)
          el = Element.new('RepowerReversalRequest')
          el.add_element('ICA').add_text(repower_reversal.ica)
          el.add_element('TransactionReference').add_text(repower_reversal.transaction_reference)
          el.add_element('ReversalReason').add_text(repower_reversal.reversal_reason)
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
          repower_reversal = RepowerReversal.new
          xml_repower_reversal = xml_body.elements['RepowerReversal']
          repower_reversal.request_id = xml_repower_reversal.elements['RequestId'].text
          repower_reversal.original_request_id = xml_repower_reversal.elements['OriginalRequestId'].text
          repower_reversal.transaction_reference = xml_repower_reversal.elements['TransactionReference'].text

          transaction_history = TransactionHistory.new
          xml_transaction_history = xml_repower_reversal.elements['TransactionHistory']

          transaction = Transaction.new
          xml_transaction = xml_transaction_history.elements['Transaction']
          transaction.type = xml_transaction.elements['Type'].text
          transaction.system_trace_audit_number = xml_transaction.elements['SystemTraceAuditNumber'].text
          transaction.network_reference_number = xml_transaction.elements['NetworkReferenceNumber'].text
          transaction.settlement_date = xml_transaction.elements['SettlementDate'].text

          response = Response.new
          xml_response = xml_transaction.elements['Response']
          response.code = xml_response.elements['Code'].text
          response.description = xml_response.elements['Description'].text
          transaction.submit_date_time = xml_transaction.elements['SubmitDateTime'].text

          transaction.response = response
          transaction_history.transaction = transaction

          repower_reversal.transaction_history = transaction_history
          repower_reversal
        end

      end

    end
  end
end
