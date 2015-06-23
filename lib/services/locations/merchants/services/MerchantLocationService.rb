require_relative '../../../../common/connector'
require_relative '../../../../common/environment'
require_relative '../../../../common/url_util'
require_relative '../../../../common/xml_util'
require_relative '../../../../services/locations/domain/merchants/Merchant'
require_relative '../../../../services/locations/domain/merchants/Merchants'
require_relative '../../../../services/locations/domain/merchants/Acceptance'
require_relative '../../../../services/locations/domain/merchants/Address'
require_relative '../../../../services/locations/domain/merchants/Location'
require_relative '../../../../services/locations/domain/merchants/CashBack'
require_relative '../../../../services/locations/domain/merchants/Features'
require_relative '../../../../services/locations/domain/common/countries/Country'
require_relative '../../../../services/locations/domain/common/country_subdivisions/CountrySubdivision'
require_relative '../../../../services/locations/domain/merchants/Point'
require_relative '../../../../services/locations/domain/merchants/PayPass'
require_relative '../../../../services/locations/domain/merchants/Topup'
require_relative '../../../../services/locations/domain/merchants/RePower'
require_relative '../../../../services/locations/domain/merchants/Products'

require 'rexml/document'
include REXML
include Mastercard::Common
include Mastercard::Services::Locations

module Mastercard
  module Services
    module Locations

      class MerchantLocationService < Connector

        SANDBOX_URL = 'https://sandbox.api.mastercard.com/merchants/v1/merchant?Format=XML'
        PRODUCTION_URL = 'https://api.mastercard.com/merchants/v1/merchant?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_merchants(options)
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
          url = url_util.add_query_parameter(url, 'Details', options.details)
          url = url_util.add_query_parameter(url, 'PageOffset', options.page_offset)
          url = url_util.add_query_parameter(url, 'PageLength', options.page_length)
          url = url_util.add_query_parameter(url, 'Category', options.category)
          url = url_util.add_query_parameter(url, 'AddressLine1', options.address_line1)
          url = url_util.add_query_parameter(url, 'AddressLine2', options.address_line2)
          url = url_util.add_query_parameter(url, 'City', options.city)
          url = url_util.add_query_parameter(url, 'CountrySubdivision', options.country_subdivision)
          url = url_util.add_query_parameter(url, 'PostalCode', options.postal_code)
          url = url_util.add_query_parameter(url, 'Country', options.country.name)
          url = url_util.add_query_parameter(url, 'Latitude', options.latitude)
          url = url_util.add_query_parameter(url, 'Longitude', options.longitude)
          url = url_util.add_query_parameter(url, 'DistanceUnit', options.distance_unit)
          url = url_util.add_query_parameter(url, 'Radius', options.radius)
          url = url_util.add_query_parameter(url, 'OfferMerchantId', options.offer_merchant_id)
        end

        def generate_return_object(xml_body)
          xml_util = XMLUtil.new

          merchants = Merchants.new
          merchants.page_offset = xml_body.elements['Merchants/PageOffset'].text
          merchants.total_count = xml_body.elements['Merchants/TotalCount'].text

          xml_merchants = xml_body.elements.to_a('Merchants/Merchant')
          merchant_array = Array.new
          xml_merchants.each do |merchant|

            tmp_merchant = Merchant.new
            tmp_merchant.id = merchant.elements['Id'].text
            tmp_merchant.name = merchant.elements['Name'].text
            tmp_merchant.website_url = merchant.elements['WebsiteUrl'].text
            tmp_merchant.phone_number = merchant.elements['PhoneNumber'].text
            tmp_merchant.category = merchant.elements['Category'].text
            location = merchant.elements['Location']

            tmp_location = Location.new
            tmp_location.name = location.elements['Name'].text
            tmp_location.distance = location.elements['Distance'].text
            tmp_location.distance_unit = location.elements['DistanceUnit'].text
            address = location.elements['Address']

            tmp_address = Address.new
            tmp_address.line1 = address.elements['Line1'].text
            tmp_address.line2 = address.elements['Line2'].text
            tmp_address.city = address.elements['City'].text
            tmp_address.postal_code = address.elements['PostalCode'].text
            country_subdivision = address.elements['CountrySubdivision']

            tmp_country_subdivision = CountrySubdivision.new
            tmp_country_subdivision.name = country_subdivision.elements['Name'].text
            tmp_country_subdivision.code = country_subdivision.elements['Code'].text
            country = address.elements['Country']

            tmp_country = Country.new
            tmp_country.name = country.elements['Name'].text
            tmp_country.code = country.elements['Code'].text
            tmp_address.country_subdivision = tmp_country_subdivision
            tmp_address.country = tmp_country
            point = location.elements['Point']

            tmp_point = Point.new
            tmp_point.latitude = point.elements['Latitude'].text
            tmp_point.longitude = point.elements['Longitude'].text
            tmp_location.point = tmp_point
            tmp_merchant.location = tmp_location


            if merchant.elements['Topup'] != nil
              tmp_topup = Topup.new
              topup = merchant.elements['Topup']
              tmp_re_power = RePower.new
              re_power = topup.elements['RePower']
              tmp_re_power.card_swipe = xml_util.verify_not_nil(re_power.elements['CardSwipe'])
              tmp_re_power.money_pak = xml_util.verify_not_nil(re_power.elements['MoneyPak'])
              tmp_topup.re_power = tmp_re_power
              tmp_merchant.topup = tmp_topup
            end

            if merchant.elements['Products'] != nil
              tmp_products = Products.new
              products = merchant.elements['Products']
              tmp_products.prepaid_travel_card = xml_util.verify_not_nil(products.elements['PrepaidTravelCard'])
              tmp_merchant.products = tmp_products
            end

            if merchant.elements['Features'] != nil
              tmp_features = Features.new
              features = merchant.elements['Features']
              tmp_cash_back = CashBack.new
              cash_back = features.elements['CashBack']
              tmp_cash_back.maximum_amount = xml_util.verify_not_nil(cash_back.elements['MaximumAmount'])
              tmp_features.cash_back = tmp_cash_back
              tmp_merchant.features = tmp_features
            end

            # At time of testing, Acceptance data was not returning as described in the documentation. Uncomment when data is corrected.

            # tmp_acceptance = Acceptance.new
            # acceptance = merchant.elements['Acceptance']
            # tmp_pay_pass = PayPass.new
            # pay_pass = acceptance.elements['PayPass']
            # tmp_pay_pass.concession = xml_util.verify_not_nil(pay_pass.elements['Concession'])
            # tmp_pay_pass.pharmacy = xml_util.verify_not_nil(pay_pass.elements['Pharmacy'])
            # tmp_pay_pass.fuel_pump = xml_util.verify_not_nil(pay_pass.elements['FuelPump'])
            # tmp_pay_pass.toll_booth = xml_util.verify_not_nil(pay_pass.elements['TollBooth'])
            # tmp_pay_pass.drive_thru = xml_util.verify_not_nil(pay_pass.elements['DriveThru'])
            # tmp_pay_pass.register = xml_util.verify_not_nil(pay_pass.elements['Register'])
            # tmp_pay_pass.ticketing = xml_util.verify_not_nil(pay_pass.elements['Ticketing'])
            # tmp_pay_pass.vending_machine = xml_util.verify_not_nil(pay_pass.elements['VendingMachine'])
            # tmp_acceptance.pay_pass = tmp_pay_pass
            # tmp_merchant.acceptance = tmp_acceptance

            merchant_array.push(tmp_merchant)
            end
          merchants.merchant = merchant_array
          merchants
        end

      end

    end
  end
end