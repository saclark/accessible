require 'simplecov'
require 'coveralls'
require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/spec'

Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start { add_filter '/test/' }
Coveralls.wear!

require 'accessible'
