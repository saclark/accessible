# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'accessible/version'

Gem::Specification.new do |spec|
  spec.name          = 'accessible'
  spec.version       = Accessible::VERSION
  spec.authors       = ['Scott Clark']
  spec.email         = ['sclarkdev@gmail.com']
  spec.summary       = 'Simple and flexible ruby app configuration.'
  spec.description   = 'A simple and flexible means of configuration for Ruby applications.'
  spec.homepage      = 'https://github.com/saclark/accessible'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib2']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake', '~> 10.1'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'coveralls', '~> 0.7'
  spec.add_development_dependency 'minitest-reporters'
end
