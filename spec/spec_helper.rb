require 'rspec'
require 'coveralls'
require 'simplecov'
require 'rspec/its'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
]
SimpleCov.start

Coveralls.wear!

require 'pad'

require 'delegate_matcher'

Dir['./spec/shared/**/*.rb'].sort.each { |f| require f}

RSpec.configure do |config|
  config.color = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
require_relative 'have_attribute_matcher'
