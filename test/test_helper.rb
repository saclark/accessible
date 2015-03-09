require 'simplecov'
require 'coveralls'
Coveralls.wear!

require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/spec'

Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)

SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start do
   add_filter '/test/'
end

require 'accessible'
