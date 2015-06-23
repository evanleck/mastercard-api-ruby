module Mastercard
  module Common

    class XMLUtil

      def verify_not_nil(value)
        if value.nil?
          nil
        else
          value.text
        end
      end

    end

  end
end

