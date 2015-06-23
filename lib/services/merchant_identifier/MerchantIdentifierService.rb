require_relative '../../common/connector'
require_relative '../../common/environment'
require_relative '../../common/url_util'
require_relative '../../services/merchant_identifier/domain/ReturnedMerchants'
require_relative '../../services/merchant_identifier/domain/Merchant'
require_relative '../../services/merchant_identifier/domain/MerchantIds'
require_relative '../../services/merchant_identifier/domain/Country'
require_relative '../../services/merchant_identifier/domain/CountrySubdivision'
require_relative '../../services/merchant_identifier/domain/Address'

require 'rexml/document'
include REXML
include Mastercard::Common
include Mastercard::Services::MerchantIdentifier

module Mastercard
  module Services
    module MerchantIdentifier

      class MerchantIdentifierService < Connector

        PRODUCTION_URL = 'https://api.mastercard.com/merchantid/v1/merchantid?Format=XML'
        SANDBOX_URL = 'https://sandbox.api.mastercard.com/merchantid/v1/merchantid?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_merchant_id(options)
          url = get_url(options)
          doc = Document.new(do_request(url, 'GET'))
          generate_return_object(doc)
        end

        def get_url(options)
          url_util = URLUtil.new
          url = SANDBOX_URL.dup
          if @environment == PRODUCTION
            url = PRODUCTION_URL.dup
          end
          url = url_util.add_query_parameter(url, 'MerchantId', options.merchant_id)
          url = url_util.add_query_parameter(url, 'Type', options.type)
        end

        def generate_return_object(xml_body)
          message = xml_body.elements['MerchantIds/Message'].text
          xml_merchants = xml_body.elements.to_a('MerchantIds/ReturnedMerchants/Merchant')
          merchant_array = Array.new
          xml_merchants.each do|xml_merchant|
            address = Address.new
            address.line1 = xml_merchant.elements['Address/Line1'].text
            address.line2 = xml_merchant.elements['Address/Line2'].text
            address.city = xml_merchant.elements['Address/City'].text
            address.postal_code = xml_merchant.elements['Address/PostalCode'].text

            country_subdivision = CountrySubdivision.new
            country_subdivision.name = xml_merchant.elements['Address/CountrySubdivision/Name'].text
            country_subdivision.code = xml_merchant.elements['Address/CountrySubdivision/Code'].text
            address.country_subdivision = country_subdivision

            country = Country.new
            country.name = xml_merchant.elements['Address/Country/Name'].text
            country.code = xml_merchant.elements['Address/Country/Code'].text
            address.country = country

            merchant = Merchant.new
            merchant.address = address
            merchant.phone_number = xml_merchant.elements['PhoneNumber'].text
            merchant.brand_name = xml_merchant.elements['BrandName'].text
            merchant.merchant_category = xml_merchant.elements['MerchantCategory'].text
            merchant.merchant_dba_name = xml_merchant.elements['MerchantDbaName'].text
            merchant.descriptor_text = xml_merchant.elements['DescriptorText'].text
            merchant.legal_corporate_name = xml_merchant.elements['LegalCorporateName'].text
            merchant.brick_count = xml_merchant.elements['BrickCount'].text
            merchant.comment = xml_merchant.elements['Comment'].text
            merchant.location_id = xml_merchant.elements['LocationId'].text
            merchant.online_count = xml_merchant.elements['OnlineCount'].text
            merchant.other_count = xml_merchant.elements['OtherCount'].text
            merchant.sole_proprietor_name = xml_merchant.elements['SoleProprietorName'].text

            merchant_array.push(merchant)
          end
          returned_merchants = ReturnedMerchants.new(merchant_array)
          merchant_ids = MerchantIds.new(message, returned_merchants)
          merchant_ids
        end

      end

    end
  end
end
