require 'spec_helper'

describe Pad do
  subject { Pad }

  let(:options)         { { some: :option }  }
  let(:builder)         { double 'builder'   }
  let(:default_builder) { Pad.config.builder }

  [:model, :entity, :value_object].each do |method|
    describe method do
      context 'with default builder' do
        it { should delegate(method).with(options).to(default_builder).with_block }
        it { should delegate(method).with.to(default_builder).with({}).with_block }
      end

      context 'with global builder' do
        before { Pad.config.builder = builder }
        after  { Pad.reset }

        it { should delegate(method).with(options).to(builder).with_block }
        it { should delegate(method).with.to(builder).with({}).with_block }
      end

      context 'with specified builder' do
        let(:options) { { builder: builder } }

        it { should delegate(method).with(options).to(builder).with({}).with_block }
      end
    end
  end
end
