require_relative '../../../common/connector'
require_relative '../../../common/environment'
require_relative '../../../common/url_util'
require_relative '../../../common/xml_util'
require_relative '../../../services/moneysend/domain/card_mapping/CreateMapping'
require_relative '../../../services/moneysend/domain/card_mapping/CreateMappingRequest'
require_relative '../../../services/moneysend/domain/card_mapping/InquireMapping'
require_relative '../../../services/moneysend/domain/card_mapping/InquireMappingRequest'
require_relative '../../../services/moneysend/domain/card_mapping/UpdateMapping'
require_relative '../../../services/moneysend/domain/card_mapping/UpdateMappingRequest'
require_relative '../../../services/moneysend/domain/card_mapping/DeleteMapping'
require_relative '../../../services/moneysend/domain/common/Address'
require_relative '../../../services/moneysend/domain/common/Mapping'
require_relative '../../../services/moneysend/domain/common/Mappings'
require_relative '../../../services/moneysend/domain/common/CardholderFullName'
require_relative '../../../services/moneysend/domain/common/ReceivingEligibility'
require_relative '../../../services/moneysend/domain/common/Currency'
require_relative '../../../services/moneysend/domain/common/Country'
require_relative '../../../services/moneysend/domain/common/Brand'

require 'rexml/document'
include REXML
include REXML
include Mastercard::Common
include Mastercard::Services::MoneySend

module Mastercard
  module Services
    module MoneySend

      class CardMappingService < Connector

        PRODUCTION_URL = 'https://api.mastercard.com/moneysend/v2/mapping/card?Format=XML'
        SANDBOX_URL = 'https://sandbox.api.mastercard.com/moneysend/v2/mapping/card?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_create_mapping(create_mapping_request)
          body = generate_create_xml(create_mapping_request)
          url = get_url
          doc = Document.new(do_request(url, 'POST', body))
          generate_return_create_object(doc)
        end

        def get_inquire_mapping(inquire_mapping_request)
          body = generate_inquire_xml(inquire_mapping_request)
          url = get_url
          doc = Document.new(do_request(url, 'PUT', body))
          generate_return_inquire_object(doc)
        end

        def get_update_mapping(update_mapping_request, options)
          body = generate_update_xml(update_mapping_request)
          url = get_mapping_id_url(options)
          doc = Document.new(do_request(url, 'PUT', body))
          generate_return_update_object(doc)
        end

        def get_delete_mapping(options)
          url = get_mapping_id_url(options)
          doc = Document.new(do_request(url, 'DELETE'))
          generate_return_delete_object(doc)
        end

        def generate_create_xml(create_mapping_request)
          doc = Document.new
          doc << XMLDecl.new(1.0, 'ISO-8859-15')
          root = doc.add_element(generate_inner_create_xml(create_mapping_request))
          doc.to_s
        end

        def generate_inquire_xml(inquire_mapping_request)
          doc = Document.new
          doc << XMLDecl.new(1.0, 'ISO-8859-15')
          root = doc.add_element(generate_inner_inquire_xml(inquire_mapping_request))
          doc.to_s
        end

        def generate_update_xml(update_mapping_request)
          doc = Document.new
          doc << XMLDecl.new(1.0, 'ISO-8859-15')
          root = doc.add_element(generate_inner_update_xml(update_mapping_request))
          doc.to_s
        end

        def generate_delete_xml(delete_mapping_request)
          doc = Document.new
          doc << XMLDecl.new(1.0, 'ISO-8859-15')
          root = doc.add_element(generate_inner_delete_xml(delete_mapping_request))
          doc.to_s
        end

        def get_url
          url = SANDBOX_URL
          if @environment == PRODUCTION
            url = PRODUCTION_URL
          end
          url
        end

        def get_mapping_id_url(options)
          url = 'https://sandbox.api.mastercard.com/moneysend/v2/mapping/card/{mappingId}?Format=XML'
          if @environment == PRODUCTION
            url = 'https://api.mastercard.com/moneysend/v2/mapping/card/{mappingId}?Format=XML'
          end
          url.gsub('{mappingId}', options.mapping_id.to_s)
        end

        def generate_inner_create_xml(create_mapping_request)
          el = Element.new('CreateMappingRequest')
          el.add_element('SubscriberId').add_text(create_mapping_request.subscriber_id)
          el.add_element('SubscriberType').add_text(create_mapping_request.subscriber_type)
          el.add_element('AccountUsage').add_text(create_mapping_request.account_usage)
          el.add_element('DefaultIndicator').add_text(create_mapping_request.default_indicator)
          el.add_element('Alias').add_text(create_mapping_request.alias)
          el.add_element('ICA').add_text(create_mapping_request.ica)
          el.add_element('AccountNumber').add_text(create_mapping_request.account_number)
          el.add_element('ExpiryDate').add_text(create_mapping_request.expiry_date)
          cardholder_full_name = el.add_element('CardholderFullName')
          cardholder_full_name.add_element('CardholderFirstName').add_text(create_mapping_request.cardholder_full_name.cardholder_first_name)
          cardholder_full_name.add_element('CardholderMiddleName').add_text(create_mapping_request.cardholder_full_name.cardholder_middle_name)
          cardholder_full_name.add_element('CardholderLastName').add_text(create_mapping_request.cardholder_full_name.cardholder_last_name)
          address = el.add_element('Address')
          address.add_element('Line1').add_text(create_mapping_request.address.line1)
          address.add_element('Line2').add_text(create_mapping_request.address.line2)
          address.add_element('City').add_text(create_mapping_request.address.city)
          address.add_element('CountrySubdivision').add_text(create_mapping_request.address.country_subdivision)
          address.add_element('PostalCode').add_text(create_mapping_request.address.postal_code)
          address.add_element('Country').add_text(create_mapping_request.address.country)
          el.add_element('DateOfBirth').add_text(create_mapping_request.date_of_birth)
          el
        end

        def generate_return_create_object(xml_body)
          create_mapping = CreateMapping.new
          xml_create_mapping = xml_body.elements['CreateMapping']
          create_mapping.request_id = xml_create_mapping.elements['RequestId'].text
          mapping = Mapping.new
          mapping.mapping_id = xml_create_mapping.elements['Mapping/MappingId'].text
          create_mapping.mapping = mapping
          create_mapping
        end

        def generate_inner_inquire_xml(inquire_mapping_request)
          el = Element.new('InquireMappingRequest')
          el.add_element('SubscriberId').add_text(inquire_mapping_request.subscriber_id)
          el.add_element('SubscriberType').add_text(inquire_mapping_request.subscriber_type)
          el.add_element('AccountUsage').add_text(inquire_mapping_request.account_usage)
          el.add_element('Alias').add_text(inquire_mapping_request.alias)
          el.add_element('DataResponseFlag').add_text(inquire_mapping_request.data_response_flag)
          el
        end

        def generate_return_inquire_object(xml_body)
          xml_util = XMLUtil.new
          inquire_mapping = InquireMapping.new
          xml_inquire_mapping = xml_body.elements['InquireMapping']
          inquire_mapping.request_id = xml_util.verify_not_nil(xml_inquire_mapping.elements['RequestId'])

          mappings = Mappings.new
          xml_mappings = xml_inquire_mapping.elements['Mappings']

          mapping_array = Array.new
          xml_mappings_array = xml_mappings.elements.to_a('Mapping')
          xml_mappings_array.each do |xml_mapping|
            mapping = Mapping.new
            mapping.mapping_id = xml_util.verify_not_nil(xml_mapping.elements['MappingId'])
            mapping.subscriber_id = xml_util.verify_not_nil(xml_mapping.elements['SubscriberId'])
            mapping.account_usage = xml_util.verify_not_nil(xml_mapping.elements['AccountUsage'])
            mapping.default_indicator = xml_util.verify_not_nil(xml_mapping.elements['DefaultIndicator'])
            mapping.alias = xml_util.verify_not_nil(xml_mapping.elements['Alias'])
            mapping.ica = xml_util.verify_not_nil(xml_mapping.elements['ICA'])
            mapping.account_number = xml_util.verify_not_nil(xml_mapping.elements['AccountNumber'])

            cardholder_full_name = CardholderFullName.new
            xml_cardholder_full_name = xml_mapping.elements['CardholderFullName']
            cardholder_full_name.cardholder_first_name = xml_util.verify_not_nil(xml_cardholder_full_name.elements['CardholderFirstName'])
            cardholder_full_name.cardholder_middle_name = xml_util.verify_not_nil(xml_cardholder_full_name.elements['CardholderMiddleName'])
            cardholder_full_name.cardholder_last_name = xml_util.verify_not_nil(xml_cardholder_full_name.elements['CardholderLastName'])
            mapping.cardholder_full_name = cardholder_full_name

            address = Address.new
            xml_address = xml_mapping.elements['Address']
            address.line1 = xml_util.verify_not_nil(xml_address.elements['Line1'])
            address.line2 = xml_util.verify_not_nil(xml_address.elements['Line2'])
            address.city = xml_util.verify_not_nil(xml_address.elements['City'])
            address.country_subdivision = xml_util.verify_not_nil(xml_address.elements['CountrySubdivision'])
            address.postal_code = xml_util.verify_not_nil(xml_address.elements['PostalCode'])
            address.country = xml_util.verify_not_nil(xml_address.elements['Country'])
            mapping.address = address

            if xml_mapping.elements['ReceivingEligibility'] != nil
              receiving_eligibility = ReceivingEligibility.new
              xml_receiving_eligibility = xml_mapping.elements['ReceivingEligibility']
              receiving_eligibility.eligible = xml_util.verify_not_nil(xml_receiving_eligibility.elements['Eligible'])

              currency = Currency.new
              currency.alpha_currency_code = xml_util.verify_not_nil(xml_receiving_eligibility.elements['Currency/AlphaCurrencyCode'])
              currency.numeric_currency_code = xml_util.verify_not_nil(xml_receiving_eligibility.elements['Currency/NumericCurrencyCode'])
              receiving_eligibility.currency = currency

              country = Country.new
              country.alpha_country_code = xml_util.verify_not_nil(xml_receiving_eligibility.elements['Country/AlphaCountryCode'])
              country.numeric_country_code = xml_util.verify_not_nil(xml_receiving_eligibility.elements['Country/NumericCountryCode'])
              receiving_eligibility.country = country

              brand = Brand.new
              brand.acceptance_brand_code = xml_util.verify_not_nil(xml_receiving_eligibility.elements['Brand/AcceptanceBrandCode'])
              brand.product_brand_code = xml_util.verify_not_nil(xml_receiving_eligibility.elements['Brand/ProductBrandCode'])
              receiving_eligibility.brand = brand

              mapping.receiving_eligibility = receiving_eligibility
            end

            mapping.expiry_date = xml_util.verify_not_nil(xml_mapping.elements['ExpiryDate'])

            mapping_array.push(mapping)
          end
          mappings.mapping = mapping_array
          inquire_mapping.mappings = mappings
          inquire_mapping
        end

        def generate_inner_update_xml(update_mapping_request)
          el = Element.new('UpdateMappingRequest')
          el.add_element('AccountUsage').add_text(update_mapping_request.account_usage)
          el.add_element('DefaultIndicator').add_text(update_mapping_request.default_indicator)
          el.add_element('Alias').add_text(update_mapping_request.alias)
          el.add_element('AccountNumber').add_text(update_mapping_request.account_number)
          el.add_element('ExpiryDate').add_text(update_mapping_request.expiry_date)
          cardholder_full_name = el.add_element('CardholderFullName')
          cardholder_full_name.add_element('CardholderFirstName').add_text(update_mapping_request.cardholder_full_name.cardholder_first_name)
          cardholder_full_name.add_element('CardholderMiddleName').add_text(update_mapping_request.cardholder_full_name.cardholder_middle_name)
          cardholder_full_name.add_element('CardholderLastName').add_text(update_mapping_request.cardholder_full_name.cardholder_last_name)
          address = el.add_element('Address')
          address.add_element('Line1').add_text(update_mapping_request.address.line1)
          address.add_element('Line2').add_text(update_mapping_request.address.line2)
          address.add_element('City').add_text(update_mapping_request.address.city)
          address.add_element('CountrySubdivision').add_text(update_mapping_request.address.country_subdivision)
          address.add_element('PostalCode').add_text(update_mapping_request.address.postal_code)
          address.add_element('Country').add_text(update_mapping_request.address.country)
          el.add_element('DateOfBirth').add_text(update_mapping_request.date_of_birth)
          el
        end

        def generate_return_update_object(xml_body)
          update_mapping = UpdateMapping.new
          xml_update_mapping = xml_body.elements['UpdateMapping']
          update_mapping.request_id = xml_update_mapping.elements['RequestId'].text
          mapping = Mapping.new
          mapping.mapping_id = xml_update_mapping.elements['Mapping/MappingId'].text
          update_mapping.mapping = mapping
          update_mapping
        end

        def generate_return_delete_object(xml_body)
          delete_mapping = DeleteMapping.new
          xml_delete_mapping = xml_body.elements['DeleteMapping']
          delete_mapping.request_id = xml_delete_mapping.elements['RequestId'].text
          mapping = Mapping.new
          mapping.mapping_id = xml_delete_mapping.elements['Mapping/MappingId'].text
          delete_mapping.mapping = mapping
          delete_mapping
        end

      end

    end
  end
end