RSpec::Matchers.define(:have_attribute) do |attribute|
  match do
    @read_only ||= false; @write_only ||= false; @read_write ||= false
    @attribute = attribute
    read_only_ok? && write_only_ok? && read_write_ok?
  end

  chain(:read_only)  { @read_only  = true }
  chain(:write_only) { @write_only = true }
  chain(:read_write) { @read_write = true }

  def description
    format('have %sattribute %p', access_description, attribute)
  end

  private

  attr_reader :attribute

  def read_only_ok?
    if instance_variable_get(:@read_only)
      send(:read_only?)
    else
      true
    end
  end

  def read_write_ok?
   if @read_write
     read_write?
   else
     true
   end
  end

  def write_only_ok?
    if @write_only
      write_only?
    else
      true
    end
  end

  def read_only?
    readable? && !writeable?
  end

  def write_only?
    !readable? && writeable?
  end

  def read_write?
    readable? && writeable?
  end

  def readable?
    actual.respond_to?(attribute)
  end

  def writeable?
    actual.respond_to?("#{attribute}=")
  end

  def access_description
    case
    when @read_write
      'read/write '
    when @read_only
      'read only '
    when @write_only
      'write only '
    else
      ''
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
  #       read_only_message(negated),
  #   ].reject(&:empty?).join(' and ')
  #
  #   message.empty? ? default : message
  # end

  # def read_only_message(negated)
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
