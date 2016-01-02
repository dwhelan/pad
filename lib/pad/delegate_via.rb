
module DelegateVia
  class << self
    def included(base)
      base.extend ClassMethods
    end
  end

  module ClassMethods
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def delegate_via(accessor_name, *method_names, &return_block)
      options    = method_names.last.is_a?(Hash) ? method_names.pop : {}
      via_method = options.fetch(:via, :map)

      mod = if const_defined?(:DelegateVia, false)
              const_get(:DelegateVia)
            else
              new_mod = Module.new do
                def self.to_s
                  "DelegateVia(#{instance_methods(false).join(', ')})"
                end
              end
              const_set(:DelegateVia, new_mod)
            end

      mod.module_eval do
        method_names.each do |method_name|
          define_method method_name do |*args, &block|
            accessor = __send__(accessor_name)
            result   = accessor.__send__(via_method) { |service| service.__send__(method_name, *args, &block) }
            return_block ? instance_exec(result, &return_block) : result
          end
        end
      end
      include mod
    end
  end
end
