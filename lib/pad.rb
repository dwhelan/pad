require 'pad/virtus'

# TODO: Move to separate gem
require 'pad/delegate_via'

require 'pad/configuration'
require 'pad/version'
require 'pad/entity'

require 'pad/services/logger'

module Pad
  class << self
    [:model, :entity, :value_object].each do |method|
      define_method method do |options = {}, &block|
        build(method, options, &block)
      end
    end

    def config
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
