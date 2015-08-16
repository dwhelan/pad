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
#
#       it { should delegate(:name).to(:author).allow_nil   }           # name         => author && author.name
#       it { should delegate(:name).to(:author).allow_nil(true)   }     # name         => author && author.name
#       it { should delegate(:name).to(:author).allow_nil(false)   }    # name         => author.name
#     end

RSpec::Matchers.define(:delegate) do |method|
  match do |delegator|
    raise 'cannot specify delegate using "with_prefix" and "via"' if @prefix && @delegator_method
    raise 'need to provide a "to"' unless @delegate

    @method = method
    @delegator = delegator

    delegate? && delegate_with_nil? && block_ok?
  end

  description do
    "delegate #{delegator_description} to #{delegate_description}#{nil_description}#{block_description}"
  end

  def failure_message
    super + ' but' + block_failure_message(false)
  end

  def failure_message_when_negated
    super + ' but' + block_failure_message(true)
  end

  chain(:to)            { |receiver|       @delegate         = receiver }
  chain(:allow_nil)     { |allow_nil=true| @nil_allowed      = allow_nil }
  chain(:via)           { |via|            @delegator_method = via }
  chain(:with_prefix)   { |prefix=nil|     @prefix           = prefix || delegate.to_s.sub(/@/, '') }
  chain(:with)          { |*args|          @expected_args    = @args = args }
  chain(:and_pass)      { |*args|          @expected_args    = args }
  chain(:with_block)    {                  @expected_block   = true  }
  chain(:without_block) {                  @expected_block   = false }

  alias_method :with_a_block,    :with_block
  alias_method :without_a_block, :without_block

  private

  attr_reader :method, :delegator, :delegate, :prefix, :expected_args

  def block_ok?
    @expected_block.nil? || @actual_block == @expected_block
  end

  def block_description
    case
      when @expected_block == true
        ' with a block'
      when @expected_block == false
        ' without a block'
      else
        ''
    end
  end

  def block_failure_message(negated)
    @expected_block.nil? ? '' : " a block was #{negated ^ @expected_block ? 'not ' : ''}passed to #{delegate}.#{method}"
  end

  def arguments_description
    @args ? "(#{expected_args.join ', '})" : ''
  end

  def delegator_description
    "#{delegator_method}#{arguments_description}"
  end

  def delegate_description
    "#{delegate}.#{method}"
  end

  def nil_description
    case
      when @nil_allowed == true
        ' with nil allowed'
      when @nil_allowed == false
        ' with nil not allowed'
      else
        ''
    end
  end

  def delegate?(test_delegate=delegate_double)
    if delegate_is_an_attribute?
      delegate_to_attribute?(test_delegate)
    else
      delegate_to_method?(test_delegate)
    end
  end

  def nil_allowed?
    !!@nil_allowed
  end

  def delegate_with_nil?
    begin
      @allowed_nil = true
      delegate?(nil)
    rescue NoMethodError
      @allowed_nil = false
    end

    nil_allowed? == @allowed_nil
  end

  def delegator_method
    @delegator_method || (prefix ? :"#{prefix}_#{method}" : method)
  end

  def delegate_is_an_attribute?
    @delegate.to_s[0] == '@'
  end

  def delegate_to_attribute?(test_delegate)
    actual_delegate = delegator.instance_variable_get(delegate)
    delegator.instance_variable_set(delegate, test_delegate)
    delegate_called?
  ensure
    delegator.instance_variable_set(delegate, actual_delegate)
  end

  def delegate_to_method?(test_delegate)
    raise "#{delegator} does not respond to #{delegate}" unless delegator.respond_to?(delegate, true)

    unless [0, -1].include?(delegator.method(delegate).arity)
      raise "#{delegator}'s' #{delegate} method does not have zero or -1 arity (it expects parameters)"
    end

    allow(delegator).to receive(delegate) { test_delegate }
    delegate_called?
  end

  def delegate_called?
    if expected_args
      delegator.send(delegator_method, *@args) {} == :called
    else
      delegator.send(delegator_method)        {} == :called
    end
  rescue RSpec::Mocks::MockExpectationError => e
    false
  end

  def delegate_double
    Object.new.tap do |delegate|
      allow(delegate).to(receive(method)) do |*args, &block|
        @actual_args  = args
        @actual_block = !block.nil?
        :called
      end
    end
  end
end
