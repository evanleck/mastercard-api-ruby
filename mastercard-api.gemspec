Gem::Specification.new do |s|
  s.name = 'mastercard-api'
  s.version = '0.1.0'

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [ 'MasterCard' ]
  s.date = '2015-06-17'
  s.description = 'MasterCard API SDK for Ruby. See https://developer.mastercard.com'
  s.summary = 'MasterCard API SDK for Ruby.'
  s.email = 'openapi@mastercard.com'
  s.homepage = 'https://developer.mastercard.com'
  s.extra_rdoc_files = [
    'LICENSE.txt',
    'README.md'
  ]

  s.files += Dir.glob('lib/**/*')
  s.licenses = [ 'MasterCard' ]
  s.require_paths = [ 'lib' ]
end
