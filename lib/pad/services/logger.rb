require 'logger'

module Pad
  module Services
    class Logger
      include Registry

      def register(*services)
        @services ||= []
        @services.concat(services)
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
