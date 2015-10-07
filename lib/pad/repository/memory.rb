module Pad
  module Repository
    class Memory
      def initialize
        self.repository = {}
      end

      def save(entity)
        repository[entity.id] = entity
      end

      def find(id)
        repository[id]
      end

      def delete(entity)
        repository[entity.id] = nil
      end

      private

      attr_accessor :repository
    end
  end
end
