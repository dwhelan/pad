require 'logger'

module Pad
  module Services
    module Logging
      class << self
        attr_accessor :service_classes, :services

        def included(base)
          @service_classes ||= []
          @service_classes << base
        end

        def register(service)
          @services ||= []
          @services << service
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

# TODO: default to standard Ruby logger?
# TODO: handle debug? et al
