# RSpec matcher to spec delegations.
# Based on https://gist.github.com/awinograd/6158961
#
# Usage:
#
#     describe Post do
#       it { should delegate(:name).to(:author)   }                     # name         => author.name
#       it { should delegate(:name).to(:@author)  }                     # name         => @author.name
#
#       it { should delegate(:name).to(:author).with_prefix }           # author_name  => author.name
#       it { should delegate(:name).to(:author).with_prefix(:writer) }  # writer_name  => author.name
#
#       it { should delegate(:name).to(:author).via(:writer) }          # writer       => author.name
#     end

RSpec::Matchers.define(:delegate) do |method|
  match do |delegator|
    raise 'cannot specify delegate using "with_prefix" and "via"' if @prefix && @delegator_method
    raise 'need to provide a "to"' unless @delegate

    @method = method
    @delegator = delegator

    delegate_with_delegate_present? && delegate_with_delegate_nil?

  end

  description do
    arguments = args ? " with arguments #{args.join ', '}" : ''
    mechanism = case
                  when @delegator_method
                    " via #{@delegator_method}"
                  when @prefix
                    " with prefix #{@prefix}"
                  else
                    ''
                end

    "delegate #{method}#{arguments} to its #{delegate}#{mechanism}"
  end

  chain(:to)          { |receiver|   @delegate         = receiver }
  chain(:via)         { |via|        @delegator_method = via }
  chain(:with_prefix) { |prefix=nil| @prefix           = prefix || delegate.to_s.sub(/@/, '') }
  chain(:with)        { |*args|      @args             = args }
  chain(:allow_nil)   { |allow_nil=true|  @nil_allowed = allow_nil }

  private

  attr_reader :method, :delegator, :delegate, :prefix, :args, :nil_allowed

  def delegate_with_delegate_present?
    if delegate_is_an_attribute?
      delegate_to_attribute?(delegate_double, :called)
    else
      delegate_to_method?
    end
  end

  def nil_allowed?
    @nil_allowed.nil? ? false : @nil_allowed
  end

  def delegate_with_delegate_nil?
    if delegate_is_an_attribute?
      begin
        delegate_to_attribute?(nil, :nil)
        @allowed_nil = true
      rescue NoMethodError
        @allowed_nil = false
      end

      nil_allowed? == @allowed_nil
    else
      true
    end
  end

  def delegator_method
    @delegator_method || (prefix ? :"#{prefix}_#{method}" : method)
  end

  def delegate_is_an_attribute?
    @delegate.to_s[0] == '@'
  end

  def delegate_to_attribute?(test_delegate, expected)
    actual_delegate = delegator.instance_variable_get(delegate)
    delegator.instance_variable_set(delegate, test_delegate)
    delegate?(expected)
  ensure
    delegator.instance_variable_set(delegate, actual_delegate)
  end

  def delegate_to_method?
    raise "#{delegator} does not respond to #{delegate}" unless delegator.respond_to?(delegate, true)

    unless [0, -1].include?(delegator.method(delegate).arity)
      raise "#{delegator}'s' #{delegate} method does not have zero or -1 arity (it expects parameters)"
    end

    allow(delegator).to receive(delegate) { delegate_double }
    delegate?(:called)
  end

  def delegate?(expected)
    if args
      delegator.send(delegator_method, *args) == expected
    else
      delegator.send(delegator_method) == expected
    end
  end

  def delegate_double
    double('delegate').tap do |delegate|
      call = receive(method)
      call = call.with(*args) if args
      allow(delegate).to(call) { :called }
    end
  end
end
