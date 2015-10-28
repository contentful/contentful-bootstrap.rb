# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'contentful_bootstrap/version'

Gem::Specification.new do |spec|
  spec.name          = "contentful_bootstrap"
  spec.version       = ContentfulBootstrap::VERSION
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
  spec.add_development_dependency "rake"
end
