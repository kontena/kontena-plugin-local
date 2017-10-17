# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kontena/plugin/local'

Gem::Specification.new do |spec|
  spec.name          = "kontena-plugin-local"
  spec.version       = Kontena::Plugin::Local::VERSION
  spec.authors       = ["Kontena, Inc."]
  spec.email         = ["info@kontena.io"]

  spec.summary       = "Kontena Local plugin"
  spec.description   = "Manage local Kontena Platform, optimized for development workflows"
  spec.homepage      = "https://github.com/kontena/kontena-plugin-local"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'kontena-cli', '>= 1.3'
  spec.add_runtime_dependency 'docker-api'
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
end
