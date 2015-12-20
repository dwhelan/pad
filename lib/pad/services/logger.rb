require 'logger'

module Pad
  module Services
    class Logger
      class << self
        def def_service_delegator(method, composite_method = :map, *args, &block)
          define_method method do |*args, &b|
            result = services.send(composite_method) { |service| service.send(method, *args, &b) }
            block ? block.call(result) : result
          end
        end

        alias_method :services_delegator, :def_service_delegator
      end

      def register(service)
        services << service
      end

      [:debug, :info, :warn, :error, :fatal, :unknown].each do |method|
        services_delegator(method, :map, 'message=nil') { |results| results.any? }
        services_delegator("#{method}?")                { |results| results.any? } unless method == :unknown
      end

      services_delegator(:<<) { |results| results.compact.inject(:+) }
      services_delegator(:log, :map, 'severity', 'message = nil', 'progname = nil') { |results| results.compact.inject(:+) }

      private

      def services
        @services ||= []
      end
    end
  end
end

# TODO: default to standard Ruby logger?
# TODO: handle progname
# TODO: handle add
# TODO: handle log
# TODO: handle <<
# TODO: handle close
# TODO: handle datetime_format
