require 'logger'

module Pad
  module Services
    class Logger
      include DelegateVia

      def register(*loggers)
        services.concat(loggers)
      end

      def services
        @services ||= []
      end

      delegate_via :services, :debug,  :info,  :warn,  :error,  :fatal,  :unknown, &:any?
      delegate_via :services, :debug?, :info?, :warn?, :error?, :fatal?, &:any?
      delegate_via :services, :add, :log, &:any?
      delegate_via :services, :<<, &:first
    end
  end
end
