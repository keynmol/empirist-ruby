# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'empirist/version'

Gem::Specification.new do |spec|
  spec.name          = "empirist"
  spec.version       = Empirist::VERSION
  spec.authors       = ["Anton Sviridov"]
  spec.email         = ["keynmol@gmail.com"]
  spec.description   = %q{Empirist interface for Ruby}
  spec.summary       = %q{Empirist interface for Ruby}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "fakefs"
  spec.add_dependency "ruby-progressbar"
end
