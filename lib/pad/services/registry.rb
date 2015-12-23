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
        def service(method_name, *args, &rblock)
          options = extract_options(*args)
          #|| :any?.to_proc

          return_blocks[method_name.to_sym] = rblock

          line = __LINE__ + 2
          method_source = <<-METHOD
            def #{method_name}(#{arg_declaration(args)} &block)
              result = services.map { |service| service.#{method_name}(#{arg_names(args)} &block) }
              result_block = self.class.return_blocks[:#{method_name}]
              result_block ? result_block.call(result) : result
            end
          METHOD

          module_eval method_source, __FILE__, line
        end

        def return_blocks
          @return_blocks ||= {}
        end

        private

        def arg_declaration(args)
          args.empty? ? '' : args.join(', ') + ','
        end

        def arg_names(args)
          args.empty? ? '' : extract_args(args).map { |arg| arg.to_s.split('=').first.strip }.join(', ') + ','
        end

        def extract_args(args)
          args.map { |arg| arg.to_s.split(',') }.flatten.map(&:strip)
        end

        def extract_options(*args)
          defaults = {composite_method: :map}
          args.last.is_a?(Hash) ? defaults.merge(args.pop) : defaults
        end
      end
    end
  end
end
