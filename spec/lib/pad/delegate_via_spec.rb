require 'spec_helper'

describe DelegateVia do
  let(:klass)     { Struct.new(:delegates) { include DelegateVia } }
  let(:delegates) { [double('delegate1').as_null_object, double('delegate2').as_null_object] }

  subject { klass.new }

  before { subject.delegates = delegates }
  before { klass.class_eval { delegate_via :delegates, :call } }

  describe 'single method' do
    it { should delegate(:call).to(*delegates) }
  end

  describe 'multiple methods' do
    before { klass.class_eval { delegate_via :delegates, :call2 } }
    it { should delegate(:call).to(*delegates) }
    it { should delegate(:call2).to(*delegates) }
  end

  describe 'arguments' do
    it { should delegate(:call).with('arg').to(*delegates) }
    it { should delegate(:call).with('arg', 'arg2', 'arg3').to(*delegates) }
  end

  describe 'blocks' do
    it { should delegate(:call).to(*delegates).with_block }
  end

  describe 'via method' do
    it 'should default to "map"' do
      should delegate(:call).to(:delegates).as(:map)
    end

    it 'should allow accessor method to be provided' do
      klass.class_eval { delegate_via :delegates, :call, via: :each }
      should delegate(:call).to(:delegates).as(:each)
    end
  end

  describe 'return value' do
    it 'with no result block should return array of result values from delegates' do
      expect(subject.call).to eq delegates
    end

    it 'should should set self to the delegator in the result block' do
      block_self = nil
      klass.class_eval { delegate_via(:delegates, :call) { block_self = self } }

      subject.call
      expect(block_self).to be subject
    end

    it 'should should pass delegate results to the result block' do
      block_result = nil
      klass.class_eval { delegate_via(:delegates, :call) { |result| block_result = result } }

      subject.call
      expect(block_result).to eq delegates
    end

    it 'should return value from the result block' do
      klass.class_eval { delegate_via(:delegates, :call) { :return_value } }
      expect(subject.call).to eq :return_value
    end
  end
end
