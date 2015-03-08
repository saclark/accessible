require 'simplecov'
SimpleCov.start { add_filter '/test/' }

require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/spec'
require 'coveralls'

Coveralls.wear!

Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

require 'accessible'
