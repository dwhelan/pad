module Pad
  module Services

    module Logging

      class << self
        def included(base)
          service_classes << base
        end

        # private

        def service_classes
          @service_classes ||= []
        end
      end
    end

    class Logger
      attr_reader :services

      def initialize
        @services = Logging.service_classes.map(&:new)
      end

      [:debug, :info, :warn, :error, :fatal, :unknown].each do |method|
        define_method(method) do |progname = nil, &block|
          log(method, progname, &block)
        end
      end

      def log(method, progname, &block)
        services.each do |service|
          service.public_send method, progname, &block
        end
      end
    end
  end
end
