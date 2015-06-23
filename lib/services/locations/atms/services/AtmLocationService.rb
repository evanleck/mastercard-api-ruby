require_relative '../../../../common/connector'
require_relative '../../../../common/environment'
require_relative '../../../../common/url_util'
require_relative '../../../../services/locations/domain/atms/Atms'
require_relative '../../../../services/locations/domain/atms/Atm'
require_relative '../../../../services/locations/domain/options/atms/AtmLocationRequestOptions'
require_relative '../../../../services/locations/domain/atms/Address'
require_relative '../../../../services/locations/domain/atms/Location'
require_relative '../../../../services/locations/domain/common/countries/Country'
require_relative '../../../../services/locations/domain/common/country_subdivisions/CountrySubdivision'
require_relative '../../../../services/locations/domain/atms/Point'

require 'rexml/document'
include REXML
include Mastercard::Common
include Mastercard::Services::Locations

module Mastercard
  module Services
    module Locations

      class AtmLocationService < Connector

        SANDBOX_URL = 'https://sandbox.api.mastercard.com/atms/v1/atm?Format=XML'
        PRODUCTION_URL = 'https://api.mastercard.com/atms/v1/atm?Format=XML'

        def initialize(consumer_key, private_key, environment)
          super(consumer_key, private_key)
          @environment = environment
        end

        def get_atms(options)
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
          url = url_util.add_query_parameter(url, 'PageOffset', options.page_offset)
          url = url_util.add_query_parameter(url, 'PageLength', options.page_length)
          url = url_util.add_query_parameter(url, 'Category', options.category)
          url = url_util.add_query_parameter(url, 'AddressLine1', options.address_line1)
          url = url_util.add_query_parameter(url, 'AddressLine2', options.address_line2)
          url = url_util.add_query_parameter(url, 'City', options.city)
          url = url_util.add_query_parameter(url, 'CountrySubdivision', options.country_subdivision)
          url = url_util.add_query_parameter(url, 'PostalCode', options.postal_code)
          url = url_util.add_query_parameter(url, 'Country', options.country)
          url = url_util.add_query_parameter(url, 'Latitude', options.latitude)
          url = url_util.add_query_parameter(url, 'Longitude', options.longitude)
          url = url_util.add_query_parameter(url, 'DistanceUnit', options.distance_unit)
          url = url_util.add_query_parameter(url, 'Radius', options.radius)
          url = url_util.add_query_parameter(url, 'SupportEMV', options.support_emv)
          url = url_util.add_query_parameter(url, 'InternationalMaestroAccepted', options.international_maestro_accepted)
        end

        def generate_return_object(xml_body)
            atms = Atms.new
            atms.page_offset = xml_body.elements['Atms/PageOffset'].text
            atms.total_count = xml_body.elements['Atms/TotalCount'].text

            atm_array = Array.new
            xml_atms = xml_body.elements.to_a('Atms/Atm')
            xml_atms.each do |atm|
                tmp_atm = Atm.new
                tmp_atm.handicap_accessible = atm.elements['HandicapAccessible'].text
                tmp_atm.camera = atm.elements['Camera'].text
                tmp_atm.availability = atm.elements['Availability'].text
                tmp_atm.access_fees = atm.elements['AccessFees'].text
                tmp_atm.owner = atm.elements['Owner'].text
                tmp_atm.shared_deposit = atm.elements['SharedDeposit'].text
                tmp_atm.surcharge_free_alliance = atm.elements['SurchargeFreeAlliance'].text
                tmp_atm.sponsor = atm.elements['Sponsor'].text
                tmp_atm.support_emv = atm.elements['SupportEMV'].text
                tmp_atm.surcharge_free_alliance_network = atm.elements['SurchargeFreeAllianceNetwork'].text

                tmp_location = Location.new
                location = atm.elements['Location']
                tmp_location.name = location.elements['Name'].text
                tmp_location.distance = location.elements['Distance'].text
                tmp_location.distance_unit = location.elements['DistanceUnit'].text

                tmp_address = Address.new
                address = location.elements['Address']
                tmp_address.line1 = address.elements['Line1'].text
                tmp_address.line2 = address.elements['Line2'].text
                tmp_address.city = address.elements['City'].text
                tmp_address.postal_code = address.elements['PostalCode'].text

                tmp_country = Country.new
                tmp_country.name = address.elements['Country/Name'].text
                tmp_country.code = address.elements['Country/Code'].text

                tmp_country_subdivision = CountrySubdivision.new
                tmp_country_subdivision.name = address.elements['CountrySubdivision/Name'].text
                tmp_country_subdivision.code = address.elements['CountrySubdivision/Code'].text

                tmp_address.country = tmp_country
                tmp_address.country_subdivision = tmp_country_subdivision

                tmp_point = Point.new
                point = location.elements['Point']
                tmp_point.latitude = point.elements['Latitude'].text
                tmp_point.longitude = point.elements['Longitude'].text

                tmp_location.point = tmp_point
                tmp_location.address = tmp_address
                tmp_atm.location = tmp_location
                atm_array.push(tmp_atm)
            end
            atms.atm = atm_array
            atms
        end

      end
    end
  end
end
