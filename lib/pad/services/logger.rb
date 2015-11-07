require 'logger'

module Pad
  module Services
    module Logging
      class << self
        attr_writer :service_classes, :services

        def included(base)
          service_classes << base
        end

        def register(service)
          services << service
        end

        def service_classes
          @service_classes ||= []
        end

        def services
          @services ||= []
        end
      end
    end

    class Logger
      attr_reader :services

      def initialize
        @services = Logging.service_classes.map(&:new) + Logging.services
      end

      [:debug, :info, :warn, :error, :fatal, :unknown].each do |method|
        define_method(method) do |progname = nil, &block|
          log(method, progname, &block)
        end
      end

      private

      def log(method, progname, &block)
        services.each do |service|
          service.public_send method, progname, &block
        end
      end
    end
  end
end

# TODO: clear and set all service_classes and services
# TODO: default to standard Ruby logger?
