require_relative '../../../common/connector'
require_relative '../../../common/environment'
require_relative '../../../common/url_util'
require_relative '../../../common/xml_util'
require_relative '../../../services/match/domain/TerminationInquiry'
require_relative '../../../services/match/domain/TerminationInquiryType'
require_relative '../../../services/match/domain/TerminationInquiryRequest'
require_relative '../../../services/match/domain/options/TerminationInquiryRequestOptions'
require_relative '../../../services/match/domain/DriversLicenseType'
require_relative '../../../services/match/domain/AddressType'
require_relative '../../../services/match/domain/MerchantType'
require_relative '../../../services/match/domain/PrincipalType'
require_relative '../../../services/match/domain/TerminatedMerchantType'
require_relative '../../../services/match/domain/MerchantMatchType'
require_relative '../../../services/match/domain/PrincipalMatchType'

require 'rexml/document'
include REXML
include Mastercard::Common
include Mastercard::Services::Match

module Mastercard
  module Services
    module Match

      class TerminationInquiryHistoryService < Connector

        SANDBOX_URL = 'https://sandbox.api.mastercard.com/fraud/merchant/v1/termination-inquiry/id?Format=XML'
        PRODUCTION_URL = 'https://api.mastercard.com/fraud/merchant/v1/termination-inquiry/id?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_termination_inquiry_history(options)
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
          url.sub! 'id', options.inquiry_reference_number

          url = url_util.add_query_parameter(url, 'PageOffset', options.page_offset)
          url = url_util.add_query_parameter(url, 'PageLength', options.page_length)
          url = url_util.add_query_parameter(url, 'AcquirerId', options.acquirer_id)
        end

        def generate_return_object(xml_body)
          xml_util = XMLUtil.new

          xml_termination_inquiry = xml_body.elements['ns2:TerminationInquiry xmlns:ns2="http://mastercard.com/termination"']

          page_offset = xml_util.verify_not_nil(xml_termination_inquiry.elements['PageOffset'])
          total_length = xml_util.verify_not_nil(xml_termination_inquiry.elements['TotalLength'])
          ref = xml_util.verify_not_nil(xml_termination_inquiry.elements['Ref'])
          transaction_reference_number = xml_util.verify_not_nil(xml_termination_inquiry.elements['TransactionReferenceNumber'])

          xml_terminated_merchants = xml_termination_inquiry.elements.to_a('TerminatedMerchant')
          terminated_merchant_array = Array.new
          xml_terminated_merchants.each do|xml_terminated_merchant|
            terminated_merchant = TerminatedMerchantType.new
            terminated_merchant.termination_reason_code = xml_util.verify_not_nil(xml_terminated_merchant.elements['TerminationReasonCode'])
            xml_merchant = xml_terminated_merchant.elements['Merchant']
            merchant = MerchantType.new
            merchant.name = xml_util.verify_not_nil(xml_merchant.elements['Name'])
            merchant.doing_business_as_name = xml_util.verify_not_nil(xml_merchant.elements['DoingBusinessAsName'])
            merchant.phone_number = xml_util.verify_not_nil(xml_merchant.elements['PhoneNumber'])

            xml_merchant_address = xml_merchant.elements['Address']
            merchant_address = AddressType.new
            merchant_address.line1 = xml_util.verify_not_nil(xml_merchant_address.elements['Line1'])
            merchant_address.line2 = xml_util.verify_not_nil(xml_merchant_address.elements['Line2'])
            merchant_address.city = xml_util.verify_not_nil(xml_merchant_address.elements['City'])
            merchant_address.country_subdivision = xml_util.verify_not_nil(xml_merchant_address.elements['CountrySubdivision'])
            merchant_address.postal_code = xml_util.verify_not_nil(xml_merchant_address.elements['PostalCode'])
            merchant_address.country = xml_util.verify_not_nil(xml_merchant_address.elements['Country'])
            merchant.address = merchant_address

            xml_principals = xml_merchant.elements.to_a('Principal')
            principal_array = Array.new
            xml_principals.each do|xml_principal|
              principal = PrincipalType.new
              principal.first_name = xml_util.verify_not_nil(xml_principal.elements['FirstName'])
              principal.last_name = xml_util.verify_not_nil(xml_principal.elements['LastName'])
              principal.national_id = xml_util.verify_not_nil(xml_principal.elements['NationalId'])
              principal.phone_number = xml_util.verify_not_nil(xml_principal.elements['PhoneNumber'])

              xml_principal_address = xml_principal.elements['Address']
              merchant_principal_address = AddressType.new
              merchant_principal_address.line1 = xml_util.verify_not_nil(xml_principal_address.elements['Line1'])
              merchant_principal_address.line2 = xml_util.verify_not_nil(xml_principal_address.elements['Line2'])
              merchant_principal_address.city = xml_util.verify_not_nil(xml_principal_address.elements['City'])
              merchant_principal_address.country_subdivision = xml_util.verify_not_nil(xml_principal_address.elements['CountrySubdivision'])
              merchant_principal_address.postal_code = xml_util.verify_not_nil(xml_principal_address.elements['PostalCode'])
              merchant_principal_address.country = xml_util.verify_not_nil(xml_principal_address.elements['Country'])

              xml_drivers_license = xml_principal.elements['DriversLicense']
              drivers_license = DriversLicenseType.new
              drivers_license.number = xml_util.verify_not_nil(xml_drivers_license.elements['Number'])
              drivers_license.country_subdivision = xml_util.verify_not_nil(xml_drivers_license.elements['CountrySubdivision'])
              drivers_license.country = xml_util.verify_not_nil(xml_drivers_license.elements['Country'])
              principal.drivers_license = drivers_license
              principal.address = merchant_principal_address
              principal_array.push(principal)
            end
            merchant.principal = principal_array
            terminated_merchant.merchant = merchant

            xml_merchant_match = xml_terminated_merchant.elements['MerchantMatch']
            merchant_match = MerchantMatchType.new
            merchant_match.name = xml_util.verify_not_nil(xml_merchant_match.elements['Name'])
            merchant_match.doing_business_as_name = xml_util.verify_not_nil(xml_merchant_match.elements['DoingBusinessAsName'])
            merchant_match.phone_number = xml_util.verify_not_nil(xml_merchant_match.elements['PhoneNumber'])
            merchant_match.address = xml_util.verify_not_nil(xml_merchant_match.elements['Address'])
            merchant_match.country_subdivision_tax_id = xml_util.verify_not_nil(xml_merchant_match.elements['CountrySubdivisionTaxId'])
            merchant_match.national_tax_id = xml_util.verify_not_nil(xml_merchant_match.elements['NationalTaxId'])

            xml_principal_matches = xml_merchant_match.elements.to_a('PrincipalMatch')
            principal_match_array = Array.new
            xml_principal_matches.each do|xml_principal_match|
              principal_match = PrincipalMatchType.new
              principal_match.name = xml_util.verify_not_nil(xml_principal_match.elements['Name'])
              principal_match.national_id = xml_util.verify_not_nil(xml_principal_match.elements['NationalId'])
              principal_match.phone_number = xml_util.verify_not_nil(xml_principal_match.elements['PhoneNumber'])
              principal_match.address = xml_util.verify_not_nil(xml_principal_match.elements['Address'])
              principal_match.drivers_license = xml_util.verify_not_nil(xml_principal_match.elements['DriversLicense'])
              principal_match_array.push(principal_match)
            end

            merchant_match.principal_match = principal_match_array
            terminated_merchant.merchant_match = merchant_match
            terminated_merchant_array.push(terminated_merchant)
          end
          termination_inquiry = TerminationInquiry.new(page_offset, total_length, ref, terminated_merchant_array)
          termination_inquiry.transaction_reference_number = transaction_reference_number
          termination_inquiry
        end

      end

    end
  end
end
