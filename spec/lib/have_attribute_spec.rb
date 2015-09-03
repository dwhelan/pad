require 'spec_helper'

describe 'have_attribute matcher' do

  let(:klass) do
    Class.new do
      attr_accessor :rw
      attr_reader   :r
    end
  end

  subject { klass.new }

  it { is_expected.to have_attribute(:rw) }
  it { is_expected.not_to have_attribute(:r) }

  describe 'description' do
    let(:matcher) { self.class.parent_groups[1].description }
    subject       { eval matcher }
    before        { subject.matches? klass.new }

    context 'have_attribute(:missing)' do
      its(:description)     { should eq 'have attribute :missing' }
      its(:failure_message) { should match /have attribute :missing/ }
    end

    context 'have_attribute(:name)' do
      its(:failure_message_when_negated) { should match /not to have attribute :name/ }
    end

    xcontext 'have_attribute(:r)' do
      its(:failure_message)  { should match /attribute :r is read_only/ }
    end
  end
end
