require 'spec_helper'

describe 'have_attribute matcher' do

  let(:klass) do
    Class.new do
      attr_reader   :r
      attr_writer   :w
      attr_accessor :rw

      def no_args=; end

      def one_arg(arg); end

      def two_args(arg1, arg2); end
      def two_args=(arg1, arg2); end
    end
  end

  subject { klass.new }

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

  describe 'reader should take no arguments' do
    it { is_expected.not_to have_attribute(:one_arg).read_only }
  end

  describe 'writer should only take one argument' do
    it { is_expected.not_to have_attribute(:no_args=).write_only            }
    it { is_expected.not_to have_attribute(:two_args=).write_only            }
  end

  describe 'messaging' do
    let(:matcher) { self.class.parent_groups[1].description }
    subject       { eval matcher }
    before        { subject.matches? klass.new }

    {
        :'have_attribute(:name)'            => 'have attribute :name',
        :'have_attribute(:name).read_only'  => 'have read only attribute :name',
        :'have_attribute(:name).write_only' => 'have write only attribute :name',
        :'have_attribute(:name).read_write' => 'have read write attribute :name',
        :'have_attribute(:rw).read_only'    => 'have read only attribute :rw',
        :'have_attribute(:rw).write_only'   => 'have write only attribute :rw',
        :'have_attribute(:w).read_only'     => 'have read only attribute :w',
        :'have_attribute(:r).write_only'    => 'have write only attribute :r',

    }.each do |expectation, expected_description|
        describe(expectation) do
          its(:description)                  { is_expected.to eq expected_description }
          its(:failure_message)              { is_expected.to match /expected .+ to #{expected_description}/ }
          its(:failure_message_when_negated) { is_expected.to match /expected .+ not to #{expected_description}/ }
        end
    end

    {
        :'have_attribute(:no_args).write_only'  => 'have write only attribute :no_args but no_args= takes 0 argument\(s\) instead of 1',
        :'have_attribute(:one_arg).read_only'   => 'have read only attribute :one_arg but one_arg takes 1 argument\(s\) instead of 0',
        # :'have_attribute(:two_args)'           => 'have attribute :no_args but two_args takes 2 argument\(s\) instead of 0 and two_args= takes 2 argument\(s\) instead of 1',

    }.each do |expectation, expected_description|
        describe(expectation) do
          its(:failure_message) { is_expected.to match /expected .+ to #{expected_description}/ }
        end
    end

    {
        :'have_attribute(:rw)'           => 'expected .+ not to have attribute :rw',
        :'have_attribute(:r).read_only'  => 'expected .+ not to have read only attribute :r',
        :'have_attribute(:w).write_only' => 'expected .+ not to have write only attribute :w'
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
