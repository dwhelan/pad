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

# RSpec matcher to spec delegations.
# From https://gist.github.com/awinograd/6158961
# Forked from https://gist.github.com/ssimeonov/5942729 with fixes
# for arity + custom prefix.
#
# Usage:
#
#     describe Post do
#       it { should delegate(:name).to(:author).with_prefix } # author_name => author.name
#       it { should delegate(:name).to(:author).with_prefix(:any) } # any_name => author.name
#       it { should delegate(:month).to(:created_at) }
#       it { should delegate(:year).to(:created_at) }
#       it { should delegate(:something).to(:'@instance_var') }
#     end
RSpec::Matchers.define :delegate do |method|
  match do |delegator|
    @method = @prefix ? :"#{@prefix}_#{method}" : method
    @delegator = delegator

    if @to.to_s[0] == '@'
      # Delegation to an instance variable
      old_value = @delegator.instance_variable_get(@to)
      begin
        @delegator.instance_variable_set(@to, receiver_double(method))
        @delegator.send(@method) == :called
      ensure
        @delegator.instance_variable_set(@to, old_value)
      end
    elsif @delegator.respond_to?(@to, true)
      unless [0,-1].include?(@delegator.method(@to).arity)
        raise "#{@delegator}'s' #{@to} method does not have zero or -1 arity (it expects parameters)"
      end
      @delegator.stub(@to).and_return receiver_double(method)
      @delegator.send(@method) == :called
    else
      raise "#{@delegator} does not respond to #{@to}"
    end
  end

  description do
    "delegate :#{@method} to its #{@to}#{@prefix ? ' with prefix' : ''}"
  end

  failure_message do |text|
    "expected #{@delegator} to delegate :#{@method} to its #{@to}#{@prefix ? ' with prefix' : ''}"
  end

  failure_message_when_negated do |text|
    "expected #{@delegator} not to delegate :#{@method} to its #{@to}#{@prefix ? ' with prefix' : ''}"
  end

  chain(:to)          { |receiver|   @to = receiver }
  chain(:with_prefix) { |prefix=nil| @prefix = prefix || @to }

  def receiver_double(method)
    double('receiver').tap do |receiver|
      receiver.stub(method).and_return :called
    end
  end
end

# RSpec::Matchers.define :delegate do |method|
#   match do |delegator|
#     @method = @prefix ? :"#{@to}_#{delegate_method}" : delegate_method
#     @delegator = delegator
#
#     if @to.is_a? Symbol
#       begin
#         @delegator.send(@to)
#       rescue NoMethodError
#         raise "#{@delegator} does not respond to #{@to}!"
#       end
#       @delegator.stub(@to).and_return double('receiver')
#       @delegator.send(@to).stub(method).and_return :called
#     else
#       @to.stub(delegate_method) { :called }
#     end
#
#     @delegator.send(method) == :called
#   end
#
#   def delegate_method
#     @as || @prefix ? :"#{@to}_#{@method}" : @method
#   end
#
#   description do
#     "delegate :#{@method} to #{@to}#{@prefix ? ' with prefix' : ''}"
#   end
#
#   failure_message do |text|
#     "expected #{@delegator} #{x} to delegate :#{method} to #{@to}#{@prefix ? ' with prefix' : ''}"
#   end
#
#   failure_message_when_negated do |text|
#     "expected #{@delegator} not to delegate :#{method} to #{@to}#{@prefix ? ' with prefix' : ''}"
#   end
#
#   chain(:to) { |receiver| @to = receiver }
#   chain(:as) { |method| @as = method }
#   chain(:with_prefix) { @prefix = true }
#  end