module Pad
  class Configuration
    attr_accessor :builder
    attr_accessor :repository

    # @api private
    def initialize(options = {})
      self.builder    = options.fetch(:builder,    Pad::Virtus)
      self.repository = options.fetch(:repository, Pad::Repository::Memory)

      yield self if block_given?
    end
  end
end
