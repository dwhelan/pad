module Pad

  module Entity

    def self.included(base)
      base.instance_eval do
        attribute :id
      end
    end

    def == (other)
      cmp?(__method__, other)
    end

    def eql?(other)
      cmp?(__method__, other)
    end

    def hash
      [self.class, id].hash
    end

    # @api private
    def cmp?(comparator, other)
      return false unless other.class == self.class

      if id.nil?
        equal?(other)
      else
        id.send(comparator, other.id)
      end
    end
  end
end
