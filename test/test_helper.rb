require 'coveralls'
Coveralls.wear!

require 'simplecov'
SimpleCov.start { add_filter '/test/' }

require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/spec'

SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)

require 'accessible'
