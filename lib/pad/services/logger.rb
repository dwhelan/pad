require 'logger'

module Pad
  module Services
    class Logger
      include Registry

      [:debug, :info, :warn, :error, :fatal, :unknown].each do |name|
        service name, &:any?

        next if name == :unknown

        service "#{name}?", &:any?
      end

      [:add, :log].each do |name|
        service name, &:any?
      end

      service(:<<) { |results| results.compact.inject(:+) }
    end
  end
end
