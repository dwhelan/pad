require 'rspec'
# require 'rspec/its'
# require 'coveralls'

require 'simplecov'

# SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
#     SimpleCov::Formatter::HTMLFormatter,
#     Coveralls::SimpleCov::Formatter
# ]
SimpleCov.start

#require 'pry'
#require 'awesome_print'

# I18n.enforce_available_locales = true
# Coveralls.wear!

require 'pad'
require_relative 'shared/entity_module'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end

require_relative 'delegate_matcher'