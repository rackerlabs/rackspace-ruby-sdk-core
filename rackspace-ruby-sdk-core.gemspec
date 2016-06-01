# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rackspace-ruby-sdk-core/version'

Gem::Specification.new do |s|
  s.name          = "rackspace-ruby-sdk-core"
  s.version       = PeaceRubySdkCore::VERSION
  s.authors       = ["Matt Darby"]
  s.email         = ["matt.darby@rackspace.com"]

  s.summary       = "Core bits of Rackspace's Ruby SDKs"
  s.description   = "Core bits of Rackspace's Ruby SDKs"
  s.homepage      = "https://github.com/rackerlabs/rackspace-ruby-sdk-core"
  s.license       = "MIT"

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rest-client"
  s.add_dependency "activesupport"
  s.add_dependency "activemodel"
  s.add_dependency "table_print"

  s.add_development_dependency "bundler", "~> 1.11"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "awesome_print"
  s.add_development_dependency "pry"
  s.add_development_dependency "rspec-core"
  s.add_development_dependency "rspec-expectations"
  s.add_development_dependency "rspec-mocks"
end
