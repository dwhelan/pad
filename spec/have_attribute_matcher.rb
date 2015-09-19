# Intended to be an RSpec extension for mutually exclusive chained methods
module RSpec
  module Matchers
    module DSL
      class Matcher
        class << self
          def chain_group(group_name, *method_names)
            define_method :"#{group_name}_match?" do
              active_method_name = method_names.find { |method_name| instance_variable_get("@#{method_name}") }
              active_method_name ? send("#{active_method_name}_match?") : true
            end

            define_method :"#{group_name}_description" do
              method_names.find { |method_name| instance_variable_get("@#{method_name}") }.to_s.gsub(%r{[_/]}, ' ')
            end

            method_names.each do |method_name|
              chain(method_name) { instance_variable_set("@#{method_name}", true) }
            end
          end
        end
      end
    end
  end
end

# Intended to be an RSpec extension for building failure messages
module RSpec
  module Matchers
    module DSL
      class Matcher
        class << self
          def failure_messages(&block)
            define_method :failure_message do
              messages = instance_eval(&block).compact.join(' and ')
              messages.empty? ? super() : format('expected %s to %s but %s', actual, description, messages)
            end
          end
        end
      end
    end
  end
end

RSpec::Matchers.define(:have_attribute) do
  match do
    exists? && access_match? && visibility_match?(:reader) && visibility_match?(:writer)
  end

  chain_group :access, :read_only, :write_only, :read_write

  chain(:with_reader) { |visibility| @reader_visibility = ensure_valid_visibility(visibility) }
  chain(:with_writer) { |visibility| @writer_visibility = ensure_valid_visibility(visibility) }

  private

  def exists?
    reader || writer
  end

  def read_only_match?
    reader_ok? && writer.nil?
  end

  def write_only_match?
    writer_ok? && reader.nil?
  end

  def read_write_match?
    reader_ok? && writer_ok?
  end

  def reader_ok?
    reader && reader.arity.eql?(0)
  end

  def writer_ok?
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
    nil
  end

  failure_messages do
    [
      arity_failure_message(reader, 0),
      arity_failure_message(writer, 1),
    ]
  end

  def arity_failure_message(method, expected_arity)
    format('%s() takes %d argument%s instead of %d', method.name, method.arity, method.arity == 1 ? '' : 's', expected_arity) if method && method.arity != expected_arity
  end

  def visibility_match?(accessor)
    method = accessor == :reader ? reader : writer
    expected_visibility = instance_variable_get(:"@#{accessor}_visibility")

    method.nil? || expected_visibility.nil? || expected_visibility == visibility(method)
  end

  def visibility(method)
    klass = method.receiver.class

    case
    when klass.private_method_defined?(method.name)
      :private
    when klass.protected_method_defined?(method.name)
      :protected
    else
      :public
    end
  end

  VALID_VISIBILITIES ||= [:private, :protected, :public]

  def ensure_valid_visibility(visibility)
    fail format('%s is an invalid visibility; should be one of %s', visibility, VALID_VISIBILITIES.join(', ')) unless VALID_VISIBILITIES.include?(visibility)
    visibility
  end
end
