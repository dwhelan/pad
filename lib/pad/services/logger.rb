require 'logger'

module Pad
  module Services
    module Logging
      class << self
        attr_reader :service_classes, :services

        def included(base)
          self.service_classes ||= []
          service_classes << base
        end

        def register(service)
          self.services ||= []
          services << service
        end

        def clear
          { services: services, service_classes: service_classes }.tap do
            self.service_classes = []
            self.services = []
          end
        end

        def restore(state)
          self.service_classes = state[:service_classes]
          self.services        = state[:services]
        end

        private

        attr_writer :service_classes, :services
      end
    end

    class Logger
      attr_reader :services

      def initialize
        @services = Logging.service_classes.map(&:new) + Logging.services
      end

      [:debug, :info, :warn, :error, :fatal, :unknown].each do |method|
        define_method(method)       { |progname = nil, &block|  log(method, progname, &block) }
        define_method("#{method}?") { log?(method) } unless method == :unknown
      end

      private

      def log(method, progname, &block)
        services.each do |service|
          service.public_send method, progname, &block
        end
      end

      def log?(method)
        services.any? do |service|
          service.public_send "#{method}?"
        end
      end
    end
  end
end

# TODO: default to standard Ruby logger?
# TODO: handle debug? et al
