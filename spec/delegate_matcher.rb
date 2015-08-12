# RSpec matcher to spec delegations.
# Based on https://gist.github.com/awinograd/6158961
# Forked from https://gist.github.com/ssimeonov/5942729 with fixes
# for arity + custom prefix.
#
# Usage:
#
#     describe Post do
#       it { should delegate(:name).to(:author) }                       # name         => author.name
#       it { should delegate(:name).to(:author).with_prefix }           # author_name  => author.name
#       it { should delegate(:name).to(:author).with_prefix(:writer) }  # writer_name  => author.name

#       it { should delegate(:name).to(:@author) }                      # name         => @author.name
#       it { should delegate(:name).to(:@author).with_prefix }          # author_name  => @author.name
#       it { should delegate(:name).to(:@author).with_prefix(:writer) } # writer_name  => @author.name

#       it { should delegate(:month).to(:created_at) }
#       it { should delegate(:year).to(:created_at) }
#       it { should delegate(:something).to(:'@instance_var') }
#     end
RSpec::Matchers.define :delegate do |method|
  match do |delegator|
    @method = method
    @delegator = delegator
    @delegator_method = @prefix ? :"#{@prefix}_#{method}" : method

    if delegate_is_an_attribute?
      delegate_to_attribute(method)
    else
      delegate_to_method(method)
    end
  end

  description do
    "delegate #{@method} to its #{@to}#{@prefix ? " with prefix #{@prefix}" : ''}"
  end

  chain(:to)          { |receiver|   @to = receiver }
  chain(:with_prefix) { |prefix=nil| @prefix = prefix || @to.to_s.sub(/@/, '') }

  private

  def delegate_is_an_attribute?
    @to.to_s[0] == '@'
  end

  def delegate_to_attribute(method)
    original_to = @delegator.instance_variable_get(@to)

    begin
      @delegator.instance_variable_set(@to, delegate_double(method))
      @delegator.send(@delegator_method) == :called
    ensure
      @delegator.instance_variable_set(@to, original_to)
    end
  end

  def delegate_to_method(method)
    raise "#{@delegator} does not respond to #{@to}" unless @delegator.respond_to?(@to, true)

    unless [0, -1].include?(@delegator.method(@to).arity)
      raise "#{@delegator}'s' #{@to} method does not have zero or -1 arity (it expects parameters)"
    end

    @delegator.stub(@to).and_return delegate_double(method)
    @delegator.send(@delegator_method) == :called
  end

  def delegate_double(method)
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
