require 'spec_helper'

module Pad
  describe Configuration do
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
      let(:builder) { double 'builder' }

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

    describe 'repository' do
      let(:repository) { double 'repository' }

      it 'should default to Pad::Repository::Memory' do
        expect(subject.repository).to be Pad::Repository::Memory
      end

      it 'should be settable' do
        subject.repository = repository
        expect(subject.repository).to be repository
      end

      it 'should be settable via initialization' do
        configuration = Configuration.new(repository: repository)
        expect(configuration.repository).to be repository
      end
    end
  end
end
