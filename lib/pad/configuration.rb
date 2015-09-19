module Pad
  class Configuration
    attr_accessor :builder

    # @api private
    def initialize(options = {})
      @builder = options.fetch(:builder, Pad::Virtus)

      yield self if block_given?
    end
  end
end

# TODO: use a Virtus value object
