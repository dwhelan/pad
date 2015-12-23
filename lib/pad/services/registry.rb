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
        def service(method, *args, &return_block)
          options = extract_options(*args)
          return_block ||= :any?.to_proc

          method = <<-END.gsub(/^ {6}/, '')
            def #{method}(#{arg_declaration(args)} &block)
              services.map { |service| service.#{method}(#{arg_names(args)} &block) }
            end
          END
          # binding.pry
          module_eval method
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
