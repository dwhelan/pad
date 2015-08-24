require 'spec_helper'

module Pad
  module Virtus
    describe Virtus do

      let(:options) { { some: :option } }

      describe 'model' do
        it { should delegate(:model).with(options).to(ModelBuilder).as(:call).with_block }
        it { should delegate(:model).with().       to(ModelBuilder).as(:call).with({})   }
      end

      it_should_behave_like 'an entity builder', Pad::Virtus
    end

    describe ModelBuilder do
      it('should subclass Virtus::ModelBuilder') { expect(ModelBuilder.ancestors[1]).to be ::Virtus::ModelBuilder }
    end
  end
end

# TODO Check for options being handled with entity
# TODO Check for block being handled with
# TODO create 'an module builder'
