require_relative '../../common/connector'
require_relative '../../common/environment'
require_relative '../../services/fraud-scoring/domain/ScoreLookup'
require_relative '../../services/fraud-scoring/domain/ScoreLookupRequest'
require_relative '../../services/fraud-scoring/domain/ScoreResponse'
require_relative '../../services/fraud-scoring/domain/TransactionDetail'

require 'rexml/document'
include REXML
include Mastercard::Services::FraudScoring
include Mastercard::Common

module Mastercard
  module Services
    module FraudScoring

      class FraudScoringService < Connector

        PRODUCTION_URL = 'https://api.mastercard.com/fraud/merchantscoring/v1/score-lookup?Format=XML'
        SANDBOX_URL = 'https://sandbox.api.mastercard.com/fraud/merchantscoring/v1/score-lookup?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_score_lookup(lookup_request)
          body = generate_xml(lookup_request)
          url = get_url
          doc = Document.new(do_request(url, 'PUT', body))
          generate_return_object(doc)
        end

        def generate_xml(lookup_request)
          doc = Document.new
          doc << XMLDecl.new(1.0, 'ISO-8859-15')
          root = doc.add_element(generate_inner_xml(lookup_request))
          doc.to_s
        end

        def generate_inner_xml(lookup_request)
          el = Element.new('ScoreLookupRequest')
          transaction_detail = el.add_element('TransactionDetail')
          transaction_detail.add_element('CustomerIdentifier').add_text(lookup_request.transaction_detail.customer_identifier)
          transaction_detail.add_element('MerchantIdentifier').add_text(lookup_request.transaction_detail.merchant_identifier)
          transaction_detail.add_element('AccountNumber').add_text(lookup_request.transaction_detail.account_number)
          transaction_detail.add_element('AccountPrefix').add_text(lookup_request.transaction_detail.account_prefix)
          transaction_detail.add_element('AccountSuffix').add_text(lookup_request.transaction_detail.account_suffix)
          transaction_detail.add_element('TransactionAmount').add_text(lookup_request.transaction_detail.transaction_amount)
          transaction_detail.add_element('TransactionDate').add_text(lookup_request.transaction_detail.transaction_date)
          transaction_detail.add_element('TransactionTime').add_text(lookup_request.transaction_detail.transaction_time)
          transaction_detail.add_element('BankNetReferenceNumber').add_text(lookup_request.transaction_detail.bank_net_reference_number)
          transaction_detail.add_element('Stan').add_text(lookup_request.transaction_detail.stan)
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
          xml_score_lookup = xml_body.elements['ScoreLookup']
          score_lookup = ScoreLookup.new
          score_lookup.customer_identifier = xml_score_lookup.elements['CustomerIdentifier'].text
          score_lookup.request_timestamp = xml_score_lookup.elements['RequestTimestamp'].text

          transaction_detail = TransactionDetail.new
          xml_transaction_detail = xml_score_lookup.elements['TransactionDetail']
          transaction_detail.customer_identifier = xml_transaction_detail.elements['CustomerIdentifier'].text
          transaction_detail.merchant_identifier = xml_transaction_detail.elements['MerchantIdentifier'].text
          transaction_detail.account_number = xml_transaction_detail.elements['AccountNumber'].text
          transaction_detail.account_prefix = xml_transaction_detail.elements['AccountPrefix'].text
          transaction_detail.account_suffix = xml_transaction_detail.elements['AccountSuffix'].text
          transaction_detail.transaction_amount = xml_transaction_detail.elements['TransactionAmount'].text
          transaction_detail.transaction_date = xml_transaction_detail.elements['TransactionDate'].text
          transaction_detail.transaction_time = xml_transaction_detail.elements['TransactionTime'].text
          transaction_detail.bank_net_reference_number = xml_transaction_detail.elements['BankNetReferenceNumber'].text
          transaction_detail.stan = xml_transaction_detail.elements['Stan'].text

          score_response = ScoreResponse.new
          xml_score_response = xml_score_lookup.elements['ScoreResponse']
          score_response.match_indicator = xml_score_response.elements['MatchIndicator'].text
          # If statement used for NO_MATCH_FOUND response. MatchIndicator will equal 4 and other values will be nil
          if xml_score_response.elements['FraudScore'] != nil
            score_response.fraud_score = xml_score_response.elements['FraudScore'].text
            score_response.reason_code = xml_score_response.elements['ReasonCode'].text
            score_response.rules_adjusted_score = xml_score_response.elements['RulesAdjustedScore'].text
            score_response.rules_adjusted_reason_code = xml_score_response.elements['RulesAdjustedReasonCode'].text
            score_response.rules_adjusted_reason_code_secondary = xml_score_response.elements['RulesAdjustedReasonCodeSecondary'].text
          end
          score_lookup.transaction_detail = transaction_detail
          score_lookup.score_response = score_response
          score_lookup
        end

      end
    end
  end
end