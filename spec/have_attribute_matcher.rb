RSpec::Matchers.define(:have_attribute) do
  match do
    access_ok?
  end

  class << self

    def chain_group(group_name, *method_names)
      define_method :"#{group_name}_ok?" do
        method_names.all? { |method_name| send("#{method_name}_ok?") }
      end

      define_method :"#{group_name}_description" do
        method_names.find{ |method_name| instance_variable_get("@#{method_name}")}.to_s.gsub(/[_\/]/, ' ')
      end

      method_names.each do |method_name|
        chain(method_name) { instance_variable_set("@#{method_name}", true) }

        define_method :"#{method_name}_ok?" do
          instance_variable_get("@#{method_name}") ? send("#{method_name}?") : true
        end
      end
    end
  end

  chain_group(:access, :read_only, :write_only, :read_write);

  def description
    format('have %s attribute %p', access_description, expected).gsub(/ +/, ' ')
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
    actual.respond_to?(expected)
  end

  def writeable?
    actual.respond_to?("#{expected}=")
  end
end
