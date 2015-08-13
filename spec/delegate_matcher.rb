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
#
#       it { should delegate(:name).to(:@author) }                      # name         => @author.name
#       it { should delegate(:name).to(:@author).with_prefix }          # author_name  => @author.name
#       it { should delegate(:name).to(:@author).with_prefix(:writer) } # writer_name  => @author.name
#
#       it { should delegate(:name).to(:author).via('writer') }         # writer       => author.name
#
#       it { should delegate(:month).to(:created_at) }
#       it { should delegate(:year).to(:created_at) }
#       it { should delegate(:something).to(:'@instance_var') }
#     end
RSpec::Matchers.define :delegate do |method|
  match do |delegator|
    raise 'cannot specify delegate using "with_prefix" and "via"' if @prefix && @delegator_method

    @method    = method
    @delegator = delegator

    if delegate_is_an_attribute?
      delegate_to_attribute
    else
      delegate_to_method
    end
  end

  description do
    "delegate #{method} to its #{delegate}#{@prefix ? " with prefix #{@prefix}" : ''}"
  end

  chain(:to)          { |receiver|   @delegate         = receiver }
  chain(:via)         { |via|        @delegator_method = via }
  chain(:with_prefix) { |prefix=nil| @prefix           = prefix || delegate.to_s.sub(/@/, '') }

  private

  attr_reader :method, :delegator, :delegate, :prefix

  def delegator_method
    @delegator_method || (prefix ? :"#{prefix}_#{method}" : method)
  end

  def delegate_is_an_attribute?
    @delegate.to_s[0] == '@'
  end

  def delegate_to_attribute
    actual_delegate = delegator.instance_variable_get(delegate)
    delegator.instance_variable_set(delegate, delegate_double)
    delegator.send(delegator_method) == :called
  ensure
    delegator.instance_variable_set(delegate, actual_delegate)
  end

  def delegate_to_method
    raise "#{delegator} does not respond to #{delegate}" unless delegator.respond_to?(delegate, true)

    unless [0, -1].include?(delegator.method(delegate).arity)
      raise "#{delegator}'s' #{delegate} method does not have zero or -1 arity (it expects parameters)"
    end

    allow(delegator).to receive(delegate) { delegate_double }
    delegator.send(delegator_method) == :called
  end

  def delegate_double
    double('receiver').tap do |receiver|
      allow(receiver).to receive(method) { :called }
    end
  end
end
