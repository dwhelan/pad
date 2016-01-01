require 'logger'

module Pad
  module Services
    module Registry
      class << self
        def included(base)
          base.extend ClassMethods
        end
      end

      module ClassMethods
        def service(accessor_name, method_name, options = {}, &return_block)
          accesor_method_name = options.fetch(:enumerable, :map)

          define_method method_name do |*args, &block|
            accessor = __send__(accessor_name)
            result   = accessor.__send__(accesor_method_name) { |service| service.__send__(method_name, *args, &block) }
            return_block ? return_block.call(result) : result
          end
        end
      end
    end
  end
end

# TODO: remove __FILE__ from backtrace
# TODO: extend Forwardable with this?
# TODO: extend ActiveSupport delegate with this?
