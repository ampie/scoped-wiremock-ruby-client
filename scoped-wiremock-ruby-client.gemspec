Gem::Specification.new do |spec|
  spec.name        = 'automation-ruby-support'
  spec.version     = '0.2.0'
  spec.date        = '2017-11-07'
  spec.summary     = 'Scoped WireMock Ruby Client'
  spec.description = 'Provides a Ruby client for WireMock with additional support for Scoped WireMock'
  spec.authors     = ['Ampie Barnard']
  spec.email       = 'ampie.barnard@standardbank.co.za'
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.require_paths = ['lib']
  spec.homepage    =
      'http://rubygems.org/gems/bla'
  spec.license       = 'MIT'
end
