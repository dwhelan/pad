require 'logger'

module Pad
  module Services
    module Registry
      class << self
        def included(base)
          base.extend ClassMethods
          base.module_eval { include InstanceMethods }
        end
      end

      module InstanceMethods
        def register(*services)
          @services ||= []
          @services += services.flatten
        end

        def services
          @services ||= []
        end
      end

      module ClassMethods
        def service(method_name, options = {}, &return_block)
          enumerable_method_name = options.fetch(:enumerable, :map)

          define_method method_name do |*args, &block|
            result = services.__send__(enumerable_method_name) { |service| service.__send__(method_name, *args, &block) }
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
