RSpec::Matchers.define(:have_attribute) do |attribute|
  match do |object|
    @attribute = attribute
    @object = object
    readable_ok? && writeable_ok?
  end

  private

  attr_reader :object, :attribute

  def readable_ok?
    readable? == expected_readable?
  end

  def readable?
    object.respond_to?(attribute)
  end

  def expected_readable?
    @expected_readable ||= true
  end

  def writeable_ok?
    writeable? == expected_writeable?
  end

  def writeable?
    object.respond_to?("#{attribute}=")
  end

  def expected_writeable?
    @expected_writeable ||= true
  end

  def failure_message
    message = failure_message_details(false)
    message.empty? ? super : message
  end

  def failure_message_when_negated
    message = failure_message_details(true)
    message.empty? ? super : message
  end

  def failure_message_details(negated)
    [
        readonly_message(negated),
    ].reject(&:empty?).join(' and ')
  end

  def readonly_message(negated)
    case
    when !readable?
      ''
    when negated ^ readable_ok?
      ''
    when negated
      'is not read only'
    else
      'is read only'
    end
  end

  # description do
  #   "foo"
  # end
  #
  # def failure_message
  #   super
  # end
  #
  # def failure_message_when_negated
  #   super
  # end


end
