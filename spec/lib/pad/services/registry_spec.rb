require 'spec_helper'

module Pad
  module Services
    describe Registry do
      let(:klass)     { Class.new { include Registry; attr_accessor :delegates } }
      let(:delegates) { [double('delegate1').as_null_object, double('delegate2').as_null_object] }

      subject { klass.new }

      before { subject.delegates = delegates }
      before { klass.class_eval { service :delegates, :call } }

      describe 'argument handling' do
        context 'with no args' do
          it { should delegate(:call).to(*delegates) }
        end

        context 'with one required arg' do
          it { should delegate(:call).with('arg').to(*delegates).with_block }
        end

        context 'with many args as separate values' do
          it { should delegate(:call).with('arg', 'arg2', 'arg3').to(*delegates) }
        end

        context 'with many args in a comma separated string' do
          it { should delegate(:call).with('arg', 'arg2', 'arg3').to(*delegates) }
        end

        context 'with variable args' do
          it { should delegate(:call).with(1).to(*delegates) }
          it { should delegate(:call).with(1, 2, 3).to(*delegates) }
        end
      end

      describe 'blocks' do
        it { should delegate(:call).to(*delegates).with_block }
      end

      describe 'enumerable method' do
        it 'should default to "map"' do
          should delegate(:call).to(:delegates).as(:map)
        end

        it 'should allow enumerable method to be provided' do
          klass.class_eval { service :delegates, :call, enumerable: :each }
          should delegate(:call).to(:delegates).as(:each)
        end
      end

      describe 'return value' do
        it 'with no result block should return array of result values from delegates' do
          expect(subject.call).to eq delegates
        end

        it 'should should pass result to result block' do
          klass.class_eval do
            class << self; attr_accessor :result end
            service(:delegates, :call) { |result| self.result = result }
          end

          subject.call
          expect(klass.result).to eq delegates
        end

        it 'with a result block should return value from the result block' do
          klass.class_eval { service(:delegates, :call) { :return_value } }
          expect(subject.call).to eq :return_value
        end
      end
    end
  end
end
