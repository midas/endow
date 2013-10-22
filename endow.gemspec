# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'endow/version'

Gem::Specification.new do |spec|
  spec.name          = "endow"
  spec.version       = Endow::VERSION
  spec.authors       = ["Jason Harrelson"]
  spec.email         = ["jason@lookforwardenterprises.com"]
  spec.description   = %q{A library to assist in consuming API endpoints.}
  spec.summary       = %q{A library to assist in consuming API endpoints.}
  spec.homepage      = "https://github.com/midas/endow"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "retryable-rb", "~> 1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
