require 'virtus'

module Pad

  module Virtus
    def self.model(options={}, &block)
      ModelBuilder.call(options, &block)
    end

    def self.entity(options={}, &block)
      EntityBuilder.call(options, &block)
    end

    class ModelBuilder < ::Virtus::ModelBuilder
    end

    class EntityBuilder < ::Virtus::ModelBuilder

      def extensions
        super + [Entity]
      end

    end
  end
end
