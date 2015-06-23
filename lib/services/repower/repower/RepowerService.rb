require_relative '../../../common/connector'
require_relative '../../../common/environment'
require_relative '../../../common/url_util'
require_relative '../../../services/repower/repower/domain/Repower'
require_relative '../../../services/repower/repower/domain/TransactionHistory'
require_relative '../../../services/repower/repower/domain/Transaction'
require_relative '../../../services/repower/repower/domain/Response'
require_relative '../../../services/repower/repower/domain/AccountBalance'

require 'rexml/document'
include REXML
include Mastercard::Common
include Mastercard::Services::Repower

module Mastercard
  module Services
    module Repower

      class RepowerService < Connector

        PRODUCTION_URL = 'https://api.mastercard.com/repower/v1/repower?Format=XML'
        SANDBOX_URL = 'https://sandbox.api.mastercard.com/repower/v1/repower?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_repower(repower_request)
          body = generate_xml(repower_request)
          url = get_url
          doc = Document.new(do_request(url, 'POST', body))
          generate_return_object(doc)
        end

        def generate_xml(repower_request)
          doc = Document.new
          doc << XMLDecl.new(1.0, 'ISO-8859-15')
          root = doc.add_element(generate_inner_xml(repower_request))
          doc.to_s
        end

        def generate_inner_xml(repower_request)
          el = Element.new('RepowerRequest')
          el.add_element('TransactionReference').add_text(repower_request.transaction_reference)
          el.add_element('CardNumber').add_text(repower_request.card_number)
          transaction_amount = el.add_element('TransactionAmount')
          transaction_amount.add_element('Value').add_text(repower_request.transaction_amount.value)
          transaction_amount.add_element('Currency').add_text(repower_request.transaction_amount.currency)
          el.add_element('LocalDate').add_text(repower_request.local_date)
          el.add_element('LocalTime').add_text(repower_request.local_time)
          el.add_element('Channel').add_text(repower_request.channel)
          el.add_element('ICA').add_text(repower_request.ica)
          el.add_element('ProcessorId').add_text(repower_request.processor_id)
          el.add_element('RoutingAndTransitNumber').add_text(repower_request.routing_and_transit_number)
          el.add_element('MerchantType').add_text(repower_request.merchant_type)
          card_acceptor = el.add_element('CardAcceptor')
          card_acceptor.add_element('Name').add_text(repower_request.card_acceptor.name)
          card_acceptor.add_element('City').add_text(repower_request.card_acceptor.city)
          card_acceptor.add_element('State').add_text(repower_request.card_acceptor.state)
          card_acceptor.add_element('PostalCode').add_text(repower_request.card_acceptor.postal_code)
          card_acceptor.add_element('Country').add_text(repower_request.card_acceptor.country)
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
          repower = Repower.new
          xml_repower = xml_body.elements['Repower']
          repower.request_id = xml_repower.elements['RequestId'].text
          repower.transaction_reference = xml_repower.elements['TransactionReference'].text

          transaction_history = TransactionHistory.new
          xml_transaction_history = xml_repower.elements['TransactionHistory']

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

          account_balance = AccountBalance.new
          xml_account_balance = xml_repower.elements['AccountBalance']
          account_balance.value = xml_account_balance.elements['Value'].text
          account_balance.currency = xml_account_balance.elements['Currency'].text

          repower.transaction_history = transaction_history
          repower.account_balance = account_balance
          repower
        end

      end

    end
  end
end
