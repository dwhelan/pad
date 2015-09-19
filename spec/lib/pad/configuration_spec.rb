require 'spec_helper'

module Pad
  describe Configuration do
    let(:builder) { double 'builder' }

    describe 'initialize' do
      it 'should allow no options' do
        Configuration.new
      end

      it 'should allow options' do
        Configuration.new(some: :option)
      end

      it 'should yield self' do
        yeilded_argument = nil
        configuration = Configuration.new { |arg| yeilded_argument = arg }
        expect(yeilded_argument).to be configuration
      end
    end

    describe 'builder' do
      it 'should default to Pad::Virtus' do
        expect(subject.builder).to be Pad::Virtus
      end

      it 'should be settable' do
        subject.builder = builder
        expect(subject.builder).to be builder
      end

      it 'should be settable via initialization' do
        configuration = Configuration.new(builder: builder)
        expect(configuration.builder).to be builder
      end
    end
  end
end
