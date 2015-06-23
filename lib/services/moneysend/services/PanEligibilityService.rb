require_relative '../../../common/connector'
require_relative '../../../common/environment'
require_relative '../../../common/url_util'
require_relative '../../../common/xml_util'
require_relative '../../../services/moneysend/domain/pan_eligibility/PanEligibilityRequest'
require_relative '../../../services/moneysend/domain/pan_eligibility/PanEligibility'
require_relative '../../../services/moneysend/domain/common/ReceivingEligibility'
require_relative '../../../services/moneysend/domain/common/SendingEligibility'
require_relative '../../../services/moneysend/domain/common/Country'
require_relative '../../../services/moneysend/domain/common/Currency'
require_relative '../../../services/moneysend/domain/common/Brand'

require 'rexml/document'
include REXML
include REXML
include Mastercard::Common
include Mastercard::Services::MoneySend

module Mastercard
  module Services
    module MoneySend

      class PanEligibilityService < Connector

        PRODUCTION_URL = 'https://api.mastercard.com/moneysend/v2/eligibility/pan?Format=XML'
        SANDBOX_URL = 'https://sandbox.api.mastercard.com/moneysend/v2/eligibility/pan?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_pan_eligibility(pan_eligibility_request)
          body = generate_xml(pan_eligibility_request)
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

        def generate_xml(pan_eligibility_request)
          doc = Document.new
          doc << XMLDecl.new(1.0, 'ISO-8859-15')
          root = doc.add_element(generate_inner_xml(pan_eligibility_request))
          doc.to_s
        end

        def generate_inner_xml(pan_eligibility_request)
          el = Element.new('PanEligibilityRequest')
          if pan_eligibility_request.receiving_account_number == nil
          el.add_element('SendingAccountNumber').add_text(pan_eligibility_request.sending_account_number)
            else if pan_eligibility_request.sending_account_number == nil
              el.add_element('ReceivingAccountNumber').add_text(pan_eligibility_request.receiving_account_number)
               else
                 el.add_element('SendingAccountNumber').add_text(pan_eligibility_request.sending_account_number)
                 el.add_element('ReceivingAccountNumber').add_text(pan_eligibility_request.receiving_account_number)
            end
          end
          el
        end

        def generate_return_object(xml_body)
          xml_util = XMLUtil.new
          pan_eligibility = PanEligibility.new
          xml_pan_eligibility = xml_body.elements['PanEligibility']
          pan_eligibility.request_id = xml_util.verify_not_nil(xml_pan_eligibility.elements['RequestId'])

          if xml_pan_eligibility.elements['SendingEligibility'] != nil
            sending_eligibility = SendingEligibility.new
            xml_sending_eligibility = xml_pan_eligibility.elements['SendingEligibility']
            sending_eligibility.eligible = xml_util.verify_not_nil(xml_sending_eligibility.elements['Eligible'])
            sending_eligibility.reason_code = xml_util.verify_not_nil(xml_sending_eligibility.elements['ReasonCode'])
            sending_eligibility.account_number = xml_util.verify_not_nil(xml_sending_eligibility.elements['AccountNumber'])
            sending_eligibility.ica = xml_util.verify_not_nil(xml_sending_eligibility.elements['ICA'])

            if xml_sending_eligibility.elements['Currency'] != nil
              currency = Currency.new
              xml_currency = xml_sending_eligibility.elements['Currency']
              currency.alpha_currency_code = xml_util.verify_not_nil(xml_currency.elements['AlphaCurrencyCode'])
              currency.numeric_currency_code = xml_util.verify_not_nil(xml_currency.elements['NumericCurrencyCode'])
              sending_eligibility.currency = currency
            end

            if xml_sending_eligibility.elements['Country'] != nil
              country = Country.new
              xml_country = xml_sending_eligibility.elements['Country']
              country.alpha_country_code = xml_util.verify_not_nil(xml_country.elements['AlphaCountryCode'])
              country.numeric_country_code = xml_util.verify_not_nil(xml_country.elements['NumericCountryCode'])
              sending_eligibility.country = country
            end

            if xml_sending_eligibility.elements['Brand'] != nil
              brand = Brand.new
              xml_brand = xml_sending_eligibility.elements['Brand']
              brand.acceptance_brand_code = xml_util.verify_not_nil(xml_brand.elements['AcceptanceBrandCode'])
              brand.product_brand_code = xml_util.verify_not_nil(xml_brand.elements['ProductBrandCode'])
              sending_eligibility.brand = brand
            end

            pan_eligibility.sending_eligibility = sending_eligibility
          end

          if xml_pan_eligibility.elements['ReceivingEligibility'] != nil
            receiving_eligibility = ReceivingEligibility.new
            xml_receiving_eligibility = xml_pan_eligibility.elements['ReceivingEligibility']
            receiving_eligibility.eligible = xml_util.verify_not_nil(xml_receiving_eligibility.elements['Eligible'])
            receiving_eligibility.reason_code = xml_util.verify_not_nil(xml_receiving_eligibility.elements['ReasonCode'])
            receiving_eligibility.account_number = xml_util.verify_not_nil(xml_receiving_eligibility.elements['AccountNumber'])
            receiving_eligibility.ica = xml_util.verify_not_nil(xml_receiving_eligibility.elements['ICA'])

            if xml_receiving_eligibility.elements['Currency'] != nil
              currency = Currency.new
              xml_currency = xml_receiving_eligibility.elements['Currency']
              currency.alpha_currency_code = xml_util.verify_not_nil(xml_currency.elements['AlphaCurrencyCode'])
              currency.numeric_currency_code = xml_util.verify_not_nil(xml_currency.elements['NumericCurrencyCode'])
              receiving_eligibility.currency = currency
            end

            if xml_receiving_eligibility.elements['Country'] != nil
              country = Country.new
              xml_country = xml_receiving_eligibility.elements['Country']
              country.alpha_country_code = xml_util.verify_not_nil(xml_country.elements['AlphaCountryCode'])
              country.numeric_country_code = xml_util.verify_not_nil(xml_country.elements['NumericCountryCode'])
              receiving_eligibility.country = country
            end

            if xml_receiving_eligibility.elements['Brand'] != nil
              brand = Brand.new
              xml_brand = xml_receiving_eligibility.elements['Brand']
              brand.acceptance_brand_code = xml_util.verify_not_nil(xml_brand.elements['AcceptanceBrandCode'])
              brand.product_brand_code = xml_util.verify_not_nil(xml_brand.elements['ProductBrandCode'])
              receiving_eligibility.brand = brand
            end

            pan_eligibility.receiving_eligibility = receiving_eligibility
          end

          pan_eligibility
        end

      end

    end
  end
end
