RSpec::Matchers.define(:have_attribute) do |attribute|
  match do
    @attribute = attribute
    readability_ok? && writeability_ok?
  end

  def initialize(*)
    super
  end

  chain(:readonly)   { @expected_readable  = true; @expected_writeable = false }
  chain(:writeonly)  { @expected_writeable = true; @expected_readable  = false }
  chain(:read_write) { @expected_writeable = true; @expected_readable  = true }

  def description
    format('have %sattribute %p', access_description, attribute)
  end

  private

  attr_reader :attribute

  def exists?
    readable? || writeable?
  end

  def readability_ok?
    @expected_readable.nil? || readable? == expected_readable?
  end

  def readable?
    actual.respond_to?(attribute)
  end

  def expected_readable?
    @expected_readable.nil? ? true : @expected_readable
  end

  def writeability_ok?
    @expected_writeable.nil? || writeable? == expected_writeable?
  end

  def writeable?
    actual.respond_to?("#{attribute}=")
  end

  def expected_writeable?
    @expected_writeable.nil? ? true : @expected_writeable
  end

  def access_description
    case
    when @expected_readable.nil? && @expected_writeable.nil?
      ''
    when expected_readable? && expected_writeable?
      'read/write '
    when expected_readable?
      'read only '
    else
      'write only '
    end
  end

  # def failure_message
  #   super
  #   # exists? ? failure_message_details(false, super) : super
  # end
  #
  # def failure_message_when_negated
  #   super
  #   # exists? ? super : failure_message_details(true, super)
  # end

  # def failure_message_details(negated, default)
  #   message = [
  #       readonly_message(negated),
  #   ].reject(&:empty?).join(' and ')
  #
  #   message.empty? ? default : message
  # end

  # def readonly_message(negated)
  #   case
  #   when @expected_readable.nil? || negated ^ readability_ok?
  #     ''
  #   when negated
  #     'is not read only'
  #   else
  #     'is read only'
  #   end
  # end

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
