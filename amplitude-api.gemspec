# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "amplitude_api/version"

Gem::Specification.new do |spec|
  spec.name          = "amplitude-api"
  spec.version       = AmplitudeAPI::VERSION
  spec.authors       = ["Alex Rakoczy"]
  spec.email         = ["arakoczy@gmail.com"]
  spec.summary       = "Send events to the Amplitude API"
  spec.description   = "Provides an integration for sending events to Amplitude"
  spec.homepage      = "https://github.com/toothrot/amplitude-api"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "pry", "~> 0.12.2"
  spec.add_development_dependency "rake", ">= 13.0.6", "< 14.0"
  spec.add_development_dependency "rspec", ">= 3.11.0", "< 4.0"
  spec.add_development_dependency "rubocop", ">= 1.28.2", "< 2.0"
  spec.add_development_dependency "rubocop-rspec", ">= 2.10.0", "< 3.0"
  spec.add_dependency "faraday", ">= 1.0", "< 3.0"
  spec.required_ruby_version = ">= 2.7"
end
