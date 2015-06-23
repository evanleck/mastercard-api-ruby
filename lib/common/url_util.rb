require 'cgi'

module Mastercard
  module Common

    class URLUtil

      def add_query_parameter(url, descriptor, value)
        if value != nil && value != ''
          url = url << '&' << descriptor << '=' << CGI.escape(value.to_s)
        end
        url
      end

    end
  end
end 