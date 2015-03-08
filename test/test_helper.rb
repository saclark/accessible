require 'simplecov'
SimpleCov.start

require 'accessible'
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/reporters'
require 'coveralls'

Coveralls.wear!
Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
