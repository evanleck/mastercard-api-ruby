module Mastercard
  module Services
    module Restaurants

      class CountrySubdivision

        attr_accessor :name
        attr_accessor :code

        def initialize(name, code)
          @name, @code = name, code
        end

      end
    end
  end
end