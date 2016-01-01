require 'logger'

module Pad
  module Services
    class Logger
      include Registry

      [:debug, :info, :warn, :error, :fatal, :unknown].each do |name|
        service name, 'message=nil', &:any?

        next if name == :unknown

        service "#{name}?", &:any?
      end

      [:add, :log].each do |name|
        service name, 'severity, message = nil, progname = nil', &:any?
      end

      service(:<<, 'message') { |results| results.compact.inject(:+) }
    end
  end
end
