# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elefunds/version'

Gem::Specification.new do |spec|
  spec.name          = 'elefunds'
  spec.version       = Elefunds::VERSION
  spec.authors       = %w(Christian Peters)
  spec.email         = %w(christian@elefunds.de)
  spec.description   = 'The elefunds SDK for ruby abstracts access to the elefunds API for convenient use in your projects.'
  spec.summary       = 'The elefunds SDK for ruby.'
  spec.homepage      = 'https://elefunds.de'
  spec.license       = 'BSD-3'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
