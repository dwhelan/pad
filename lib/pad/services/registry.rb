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
          options = extract_options(args)

          define_method method_name do |*args, &block|
            result = services.__send__(options[:enumerable]) { |service| service.__send__(method_name, *args, &block) }
            rblock ? rblock.call(result) : result
          end
        end

        def result_blocks
          @return_blocks ||= {}
        end

        private

        def extract_options(args)
          defaults = { enumerable: :map }
          args.last.is_a?(Hash) ? defaults.merge(args.pop) : defaults
        end
      end
    end
  end
end

# TODO: dont' declare method parameters
# TODO: remove __FILE__ from backtrace
