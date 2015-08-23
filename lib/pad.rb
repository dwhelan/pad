require 'pad/configuration'
require 'pad/version'
require 'pad/entity'

module Pad

  class << self
    def model(options={}, &block)
      build(:model, options, &block)
    end

    def entity(options={}, &block)
      build(:entity, options, &block)
    end

    def config(&block)
      yield configuration if block_given?
      configuration
    end

    def reset
      @configuration = Configuration.new
    end

    # @api private
    def build(method, options, &block)
      options = options.dup
      builder(options).public_send(method, options, &block)
    end

    # @api private
    def builder(options)
      options.delete(:builder) || configuration.builder
    end

    # @api private
    def configuration
      @configuration ||= Configuration.new
    end

  end
end
