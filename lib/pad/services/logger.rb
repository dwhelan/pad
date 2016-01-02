require 'logger'

module Pad
  module Services
    class Logger
      include DelegateVia

      def register(*loggers)
        self.loggers.concat(loggers)
      end

      def loggers
        @loggers ||= []
      end

      delegate_via :loggers, :debug,  :info,  :warn,  :error,  :fatal, :unknown, &:any?
      delegate_via :loggers, :debug?, :info?, :warn?, :error?, :fatal?,          &:any?

      delegate_via :loggers, :add, :log, &:any?
      delegate_via :loggers, :<<,        &:first
    end
  end
end
