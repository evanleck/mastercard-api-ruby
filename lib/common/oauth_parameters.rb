module Mastercard
  module Common

    class OAuthParameters
      
      attr_accessor :params

      def initialize()
         self.params = Hash.new
      end
       
      # add a parameter to the hash and as an instance variable to the class
      def add_parameter(key, value)
         self.params[key.to_sym] = value
         self.class.send(:define_method, key) do
           value
         end
      end
        
    end
  end
end 