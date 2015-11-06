module Pad
  class Configuration
    attr_accessor :builder
    attr_accessor :repository

    # @api private
    def initialize(options = {})
      self.builder = options.fetch(:builder, Pad::Virtus)

      yield self if block_given?
    end
  end
end
