require 'spec_helper'

require_relative 'model_context'

describe Pad do

  subject       { Pad }
  let(:options) { { some: :option } }
  let(:builder) { Class.new {def to_s; 'builder' end}.new }

  [:model, :model].each do |method|
    describe method do
      context 'with default builder' do
        it { should delegate(method).with(options).to(Pad::Virtus).with_block }
        it { should delegate(method).with().to(Pad::Virtus).with({}).with_block }
      end

      context 'with global builder' do
        before { Pad.config.builder = builder }
        after  { Pad.reset }

        it { should delegate(method).with(options).to(builder).with_block }
        it { should delegate(method).with().to(builder).with({}).with_block }
      end

      context 'with specified builder' do
        let(:options) { { builder: builder } }

        it { should delegate(method).with(options).to(builder).with({}).with_block }
      end
    end
  end
end
