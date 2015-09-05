require 'spec_helper'

describe 'have_attribute matcher' do

  let(:klass) do
    Class.new do
      attr_accessor :rw
      attr_reader   :r
      attr_writer   :w
    end
  end

  subject { klass.new }

  describe 'attr_accessor :rw' do
    it { is_expected.to     have_attribute(:rw)            }
    it { is_expected.to     have_attribute(:rw).read_write }
    it { is_expected.not_to have_attribute(:rw).readonly   }
    it { is_expected.not_to have_attribute(:rw).writeonly  }
  end

  describe 'attr_reader :r' do
    it { is_expected.to     have_attribute(:r)            }
    it { is_expected.to     have_attribute(:r).readonly   }
    it { is_expected.not_to have_attribute(:r).writeonly  }
    it { is_expected.not_to have_attribute(:r).read_write }
  end

  describe 'attr_writer :w' do
    it { is_expected.to     have_attribute(:w)            }
    it { is_expected.to     have_attribute(:w).writeonly  }
    it { is_expected.not_to have_attribute(:w).readonly   }
    it { is_expected.not_to have_attribute(:w).read_write }
  end

  describe 'messaging' do
    let(:matcher) { self.class.parent_groups[1].description }
    subject       { eval matcher }
    before        { subject.matches? klass.new }

    {
        :'have_attribute(:name)'            => 'have attribute :name',
        :'have_attribute(:name).readonly'   => 'have read only attribute :name',
        :'have_attribute(:name).writeonly'  => 'have write only attribute :name',
        :'have_attribute(:name).read_write' => 'have read/write attribute :name',
        :'have_attribute(:rw).readonly'     => 'have read only attribute :rw',
        :'have_attribute(:rw).writeonly'    => 'have write only attribute :rw',
        :'have_attribute(:w).readonly'      => 'have read only attribute :w',
        :'have_attribute(:r).writeonly'     => 'have write only attribute :r',

    }.each do |expectation, expected_description|
        describe(expectation) do
          its(:description)     { is_expected.to eq expected_description }
          its(:failure_message) { is_expected.to match /expected .+ to #{expected_description}/ }
          its(:failure_message_when_negated) { is_expected.to match /expected .+ not to #{expected_description}/ }
        end
    end

    {
        :'have_attribute(:rw)'          => 'expected .+ not to have attribute :rw',
        :'have_attribute(:r).readonly'  => 'expected .+ not to have read only attribute :r',
        :'have_attribute(:w).writeonly' => 'expected .+ not to have write only attribute :w'
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
