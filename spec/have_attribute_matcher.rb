class RSpec::Matchers::DSL::Matcher
  class << self
    def chain_group(group_name, *method_names)
      define_method :"#{group_name}_match?" do
        active_method_name = method_names.find{ |method_name| instance_variable_get("@#{method_name}")}
        active_method_name ? send("#{active_method_name}_match?") : true
      end

      define_method :"#{group_name}_description" do
        method_names.find{ |method_name| instance_variable_get("@#{method_name}")}.to_s.gsub(/[_\/]/, ' ')
      end

      method_names.each do |method_name|
        chain(method_name) { instance_variable_set("@#{method_name}", true) }
      end
    end
  end
end

class RSpec::Matchers::DSL::Matcher
  class << self
    def failure_messages(*method_names)
      define_method :failure_message do
        messages = method_names.map{|m| send(m)}.compact.join(' and ')
        messages.empty? ? super() : format('expected %s to %s but %s', actual, description, messages)
      end
    end
  end
end

RSpec::Matchers.define(:have_attribute) do
  match { access_match? }

  chain_group :access, :read_only, :write_only, :read_write

  def description
    format('have %s attribute %p', access_description, expected).gsub(/ +/, ' ')
  end

  private

  def read_only_match?
    readable? && !writeable?
  end

  def write_only_match?
    !readable? && writeable?
  end

  def read_write_match?
    readable? && writeable?
  end

  def readable?
    reader && reader.arity.eql?(0)
  end

  def writeable?
    writer && writer.arity.eql?(1)
  end

  def reader
    method(expected)
  end

  def writer
    method("#{expected}=")
  end

  def method(name)
    actual.method(name)
    rescue NameError
  end

  failure_messages :reader_failure_message, :writer_failure_message

  def reader_failure_message
    arity_failure_message(reader, 0)
  end

  def writer_failure_message
    arity_failure_message(writer, 1)
  end

  def arity_failure_message(method, expected_arity)
    format('%s() takes %d argument%s instead of %d', method.name, method.arity, method.arity == 1 ? '' : 's', expected_arity) if method && method.arity != expected_arity
  end
end
