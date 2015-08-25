require 'virtus'

module Pad

  module Virtus
    [:model, :value_object].each do |method|
      define_singleton_method method do |options={}, &block|
        ::Virtus.public_send(method, options, &block)
      end
    end

    def self.entity(options={}, &block)
      EntityBuilder.call(options, &block)
    end

    class EntityBuilder < ::Virtus::ModelBuilder
      def extensions
        super + [Entity]
      end
    end
  end
end
