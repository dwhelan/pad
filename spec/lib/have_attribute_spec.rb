require 'spec_helper'

shared_context 'matcher messages' do
  let(:matcher) { self.class.parent_groups[1].description }
  subject       { eval matcher }
  before        { subject.matches? klass.new }
end

describe 'have_attribute matcher' do
  subject { klass.new }

  describe 'basic attributes' do
    let(:klass) do
      Class.new do
        attr_reader   :r
        attr_writer   :w
        attr_accessor :rw
      end
    end

    describe 'attr_reader :r' do
      it { is_expected.to     have_attribute(:r)            }
      it { is_expected.to     have_attribute(:r).read_only  }
      it { is_expected.not_to have_attribute(:r).write_only }
      it { is_expected.not_to have_attribute(:r).read_write }
    end

    describe 'attr_writer :w' do
      it { is_expected.to     have_attribute(:w)            }
      it { is_expected.to     have_attribute(:w).write_only }
      it { is_expected.not_to have_attribute(:w).read_only  }
      it { is_expected.not_to have_attribute(:w).read_write }
    end

    describe 'attr_accessor :rw' do
      it { is_expected.to     have_attribute(:rw)            }
      it { is_expected.to     have_attribute(:rw).read_write }
      it { is_expected.not_to have_attribute(:rw).read_only  }
      it { is_expected.not_to have_attribute(:rw).write_only }
    end

    it_behaves_like 'matcher messages' do
      {
          :'have_attribute(:name)'            => 'have attribute :name',
          :'have_attribute(:name).read_only'  => 'have attribute :name read only',
          :'have_attribute(:name).write_only' => 'have attribute :name write only',
          :'have_attribute(:name).read_write' => 'have attribute :name read write',
          :'have_attribute(:rw).read_only'    => 'have attribute :rw read only',
          :'have_attribute(:rw).write_only'   => 'have attribute :rw write only',
          :'have_attribute(:w).read_only'     => 'have attribute :w read only',
          :'have_attribute(:r).write_only'    => 'have attribute :r write only',

      }.each do |expectation, expected_description|
        describe(expectation) do
          its(:description)                  { is_expected.to eql expected_description }
          its(:failure_message)              { is_expected.to match /expected .+ to #{expected_description}/ }
          its(:failure_message_when_negated) { is_expected.to match /expected .+ not to #{expected_description}/ }
        end
      end

      {
          :'have_attribute(:rw)'           => 'expected .+ not to have attribute :rw',
          :'have_attribute(:r).read_only'  => 'expected .+ not to have attribute :r read only',
          :'have_attribute(:w).write_only' => 'expected .+ not to have attribute :w write only'
      }.each do |expectation, expected_description|
        describe(expectation) do
          its(:failure_message_when_negated) { is_expected.to match /#{expected_description}/ }
        end
      end

      context 'have_attribute(:rw)' do
        its(:failure_message_when_negated) { is_expected.to match /not to have attribute :rw/ }
      end
    end
  end

  describe 'method arity' do
    let(:klass) do
      Class.new do
        def no_args=; end

        def one_arg(arg); end

        def two_args(arg1, arg2);  end
        def two_args=(arg1, arg2); end
      end
    end

    describe 'reader should take no arguments' do
      it { is_expected.not_to have_attribute(:one_arg).read_only }
    end

    describe 'writer should take one argument' do
      it { is_expected.not_to have_attribute(:no_args=).write_only  }
      it { is_expected.not_to have_attribute(:two_args=).write_only }
    end

    it_behaves_like 'matcher messages' do
      {
          :'have_attribute(:no_args).write_only' => 'have attribute :no_args write only but no_args=\(\) takes 0 arguments instead of 1',
          :'have_attribute(:one_arg).read_only'  => 'have attribute :one_arg read only but one_arg\(\) takes 1 argument instead of 0',
          :'have_attribute(:two_args)'           => 'have attribute :two_args but two_args\(\) takes 2 arguments instead of 0 and two_args=\(\) takes 2 arguments instead of 1',

      }.each do |expectation, expected_description|
        describe(expectation) do
          its(:failure_message) { is_expected.to match /expected .+ to #{expected_description}/ }
        end
      end
    end
  end

  describe 'method visibility' do
    let(:klass) do
      Class.new do
        def public_reader; end
        def public_writer=(arg); end

        protected
        def protected_reader; end
        def protected_writer=(arg); end

        private
        def private_reader; end
        def private_writer=(arg); end
      end
    end

    [:private, :protected, :public].each do |visibility|
      [:private, :protected, :public].each do |prefix|
        if visibility == prefix
          it { is_expected.to have_attribute(:"#{prefix}_reader").with_reader(visibility) }
          it { is_expected.to have_attribute(:"#{prefix}_writer").with_writer(visibility) }
        else
          it { is_expected.not_to have_attribute(:"#{prefix}_reader").with_reader(visibility) }
          it { is_expected.not_to have_attribute(:"#{prefix}_writer").with_writer(visibility) }
        end
        it { is_expected.not_to have_attribute(:missing).with_reader(visibility) }
        it { is_expected.not_to have_attribute(:missing).with_writer(visibility) }
      end
    end

    it_behaves_like 'matcher messages' do
      {
          :'have_attribute(:private_reader).with_reader(:private)'     => 'have attribute :private_reader with reader :private',
          :'have_attribute(:protected_reader).with_reader(:protected)' => 'have attribute :protected_reader with reader :protected',
          :'have_attribute(:public_reader).with_reader(:public)'       => 'have attribute :public_reader with reader :public',

      }.each do |expectation, expected_description|
        describe(expectation) do
          its(:description)     { is_expected.to eql expected_description }
          its(:failure_message) { is_expected.to match /expected .+ to #{expected_description}/ }
          its(:failure_message_when_negated) { is_expected.to match /expected .+ not to #{expected_description}/ }
        end
      end
    end

    it 'should fail if the reader visibility is invalid' do
      expect { have_attribute(:private_reader).with_reader(:foo) }.to raise_error do |error|
        expect(error.message).to match /foo is an invalid visibility; should be one of private, protected, public/
      end
    end

    it 'should fail if the write visibility is invalid' do
      expect { have_attribute(:private_writer).with_writer(:foo) }.to raise_error do |error|
        expect(error.message).to match /foo is an invalid visibility; should be one of private, protected, public/
      end
    end
  end
end
