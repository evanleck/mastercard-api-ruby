require 'mastercard_api'

connector = Connector.new('820oCPqU4KAUEAwy0I6_Xf1dkjAlfSrEbSfeIq961563e1f8!414d686c777974526d2f71367141505a68304673746b633d', 'C:\Users\JBK0718\dev\mastercard\keystore\sandbox\414d686c777974526d2f71367141505a68304673746b633d.p12', 'unreal')

response_body = connector.do_request('https://sandbox.api.mastercard.com/fraud/loststolen/v1/account-inquiry?Format=XML','PUT','<AccountInquiry><AccountNumber>5343434343434343</AccountNumber></AccountInquiry>')
puts(response_body)

puts('SIGNATURE BASE STRING:')
puts(connector.signature_base_string)
puts('SIGNED SIGNATURE BASE STRING:')
puts(connector.signed_signature_base_string)
puts('AUTH HEADER:')
puts(connector.auth_header)
