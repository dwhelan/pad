class RSpec::Matchers::DSL::Matcher
  class << self
    def chain_group(group_name, *method_names)
      define_method :"#{group_name}_match?" do
        active_method_name = method_names.find{ |method_name| instance_variable_get("@#{method_name}")}
        active_method_name ? send("#{active_method_name}?") : true
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

RSpec::Matchers.define(:have_attribute) do
  match do
    access_match?
  end

  chain_group(:access, :read_only, :write_only, :read_write)

  def description
    case
    when reader && !readable?
      format('have %s attribute %p but the reader method %s takes %d argument(s) instead of 0', access_description, expected, expected, reader.arity).gsub(/ +/, ' ')
    else
      format('have %s attribute %p', access_description, expected).gsub(/ +/, ' ')
    end
  end

  private

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
end
