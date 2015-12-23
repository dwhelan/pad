require 'spec_helper'

module Pad
  module Services
    describe Registry do

      let(:klass)    { Class.new { include Registry } }
      let(:services) { [double('service1').as_null_object, double('service2').as_null_object ] }

      subject { klass.new }

      before { subject.register services }

      describe 'argument handling' do
        context 'with no args' do
          before { klass.class_eval { service :call } }

          it { should delegate(:call).to(*services) }
        end

        context 'with one required arg' do
          before { klass.class_eval { service :call, :arg } }

          it { should delegate(:call).with('arg').to(*services).with_block }
        end

        context 'with optional arg' do
          before { klass.class_eval { service :call, 'arg = :default' } }

          it { should delegate(:call).with().to(*services).with(:default) }
          it { should delegate(:call).with('value').to(*services).with('value') }
        end

        context 'with many args as separate values' do
          before { klass.class_eval { service :call, :arg1, :arg2, :arg3} }

          it { should delegate(:call).with('arg', 'arg2', 'arg3').to(*services) }
        end

        context 'with many args in a comma separated string' do
          before { klass.class_eval { service :call, 'arg1, arg2, arg3' } }

          it { should delegate(:call).with('arg', 'arg2', 'arg3').to(*services) }
        end

        context 'with many args in a comma separated string' do
          before { klass.class_eval { service :call, 'arg1=1, arg2=2, arg3=3' } }

          it { should delegate(:call).with().to(*services).with(1,2,3) }
        end

        context 'with many args in a comma separated string and separately' do
          before { klass.class_eval { service :call, 'arg1=1', 'arg2=2, arg3=3' } }

          it { should delegate(:call).with().to(*services).with(1,2,3) }
        end

        context 'with variable args' do
          before { klass.class_eval { service :call, 'arg1, *args' } }

          it { should delegate(:call).with(1).to(*services) }
          it { should delegate(:call).with(1, 2, 3).to(*services) }
        end
      end

      describe 'delegating blocks' do
        before { klass.class_eval { service :call } }

        it { should delegate(:call).to(*services).with_block }
      end

      describe 'return value' do

        it 'with no result block should return array of return values from services' do
          klass.class_eval { service :call }
          expect(subject.call).to eq services
        end

        it 'should should pass result to result block' do
          klass.class_eval do
            class << self; attr_accessor :result end
            service(:call) { |result| self.result = result }
          end

          subject.call
          expect(klass.result).to eq services
        end

        it 'with a result block should return value from the result block' do
          klass.class_eval { service(:call) { :return_value } }

          expect(subject.call).to eq :return_value
        end
      end
    end
  end
end
