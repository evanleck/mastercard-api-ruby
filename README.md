mastercard-api

===================

Ruby implementation of the Mastercard Open API


# Build Gem

```
gem build mastercard-api.gemspec
```

# Use the Ruby gem

```
require 'mastercard_api'
```

# Example of Use

Here is an example of how to use the Ruby gem for accessing the
Lost/Stolen API:

```ruby
require 'mastercard_api'

SANDBOX_CONSUMER_KEY = '<consumer_key>'

# Path to the private key in .p12 format.
SANDBOX_PRIVATE_KEY_PATH = '</path/to/private/key>'

private_key = OpenSSL::PKCS12.new(File.open(SANDBOX_PRIVATE_KEY_PATH), '<password>').key

service =
Mastercard::Services::LostStolen::LostStolenService.new(SANDBOX_CONSUMER_KEY,
private_key, 'SANDBOX')

account = service.get_account('5343434343434343')

puts account.listed
puts account.reason
```
