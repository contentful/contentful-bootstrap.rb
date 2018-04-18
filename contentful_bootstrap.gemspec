# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'contentful/bootstrap/version'

Gem::Specification.new do |spec|
  spec.name          = "contentful_bootstrap"
  spec.version       = Contentful::Bootstrap::VERSION
  spec.authors       = ["David Litvak Bruno"]
  spec.email         = ["david.litvakb@gmail.com"]
  spec.summary       = %q{Contentful CLI tool for getting started with Contentful}
  spec.homepage      = "https://www.contentful.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency 'rake', '< 11.0'
  spec.add_development_dependency 'public_suffix', '< 1.5'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency "vcr", '~> 2.9'
  spec.add_development_dependency "webmock", '~> 1.24'
  spec.add_development_dependency "rr"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency 'listen', '~> 3.0'
  spec.add_development_dependency "guard-rubocop"
  spec.add_development_dependency "rubocop", "~> 0.49"

  spec.add_runtime_dependency "launchy"
  spec.add_runtime_dependency "contentful-management", '~> 2.0', '>= 2.0.2'
  spec.add_runtime_dependency "contentful", "~> 2.6.0"
  spec.add_runtime_dependency "inifile"
end
