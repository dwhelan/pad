require 'spec_helper'

module Pad
  describe Virtus do
    it_should_behave_like 'an entity builder'
    it_should_behave_like 'a model builder'
    it_should_behave_like 'a value object builder'
  end
end
