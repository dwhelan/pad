require 'spec_helper'

require_relative 'model_context'

module Pad
  describe '.model' do

    include_examples 'a model builder', Pad.method(:model), Virtus::ModelBuilder
  end
end
