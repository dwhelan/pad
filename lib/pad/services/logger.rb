require 'logger'

module Pad
  module Services
    class Logger
      include Registry

      def register(*services)
        @services ||= []
        @services += services.flatten
      end

      def services
        @services ||= []
      end

      [:debug, :info, :warn, :error, :fatal, :unknown].each do |name|
        service :services, name, &:any?

        next if name == :unknown

        service :services, "#{name}?", &:any?
      end

      [:add, :log].each do |name|
        service :services, name, &:any?
      end

      service :services, :<<, &:first
    end
  end
end
