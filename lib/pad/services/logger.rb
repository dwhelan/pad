require 'logger'

module Pad
  module Services
    class Logger
      class << self
        def service(method, *args, &return_block)
          options = extract_options(*args)
          return_block ||= :any?.to_proc

          define_method method do |*a, &block|
            result = services.send(options[:composite_method]) { |service| service.send(method, *a, &block) }
            return_block ? return_block.call(result) : result
          end
        end

        private

        def extract_options(*args)
          defaults = { composite_method: :map }
          args.last.is_a?(Hash) ? defaults.merge(args.pop) : defaults
        end
      end

      def register(*services)
        @services ||= []
        @services += services.flatten
      end

      def services
        @services ||= []
      end

      [:debug, :info, :warn, :error, :fatal].each do |severity|
        service severity, 'message=nil'
        service "#{severity}?"
      end

      service :unknown, 'message=nil'

      service :<< do |results|
        results.compact.inject(:+)
      end

      service :add, 'severity, message = nil, progname = nil'
      service :log, 'severity, message = nil, progname = nil'
    end
  end
end
