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
        def delegate_via(accessor_name, *method_names, &return_block)
          options         = method_names.last.is_a?(Hash) ? method_names.pop : {}
          via_method_name = options.fetch(:via, :map)

          method_names.each do |method_name|
            define_method method_name do |*args, &block|
              accessor = __send__(accessor_name)
              result   = accessor.__send__(via_method_name) { |service| service.__send__(method_name, *args, &block) }
              return_block ? instance_exec(result, &return_block) : result
            end
          end
        end
      end
    end
  end
end

# TODO: remove __FILE__ from backtrace
# TODO: extend Forwardable with this?
# TODO: extend ActiveSupport delegate with this?
