# noinspection RubyResolve
require 'spec_helper'
require 'rspec/its'

describe 'Delegate matcher' do
  let(:post) do
    Class.new do
      attr_accessor :author

      def name
        author.name
      end

      def name2
        author && author.name2
      end

      def author_name
        author.name
      end

      def writer
        author.name
      end

      def writer_name
        author.name
      end

      def name_with_salutation(salutation)
        author.name_with_salutation(salutation)
      end

      def full_name(salutation, credentials)
        author.full_name(salutation, credentials)
      end

      def age
        60
      end

    end.new
  end

  let(:author) do
    Class.new do
      def name
        'Catherine Asaro'
      end

      def name2
        'Catherine Asaro'
      end

      def name_with_salutation(salutation)
        "#{salutation} #{name}"
      end

      def full_name(salutation, credentials)
        "#{name_with_salutation(salutation)}, #{credentials}"
      end
    end.new
  end

  subject { post }
  before  { post.author = author }

  describe 'test support' do
    its(:name)        { should eq 'Catherine Asaro' }
    its(:author_name) { should eq 'Catherine Asaro' }
    its(:writer)      { should eq 'Catherine Asaro' }
    its(:writer_name) { should eq 'Catherine Asaro' }
    its(:age)         { should eq 60                }

    it { expect(post.name_with_salutation('Ms.')).to eq 'Ms. Catherine Asaro'}
    it { expect(post.full_name('Ms.', 'Phd')).to     eq 'Ms. Catherine Asaro, Phd'}
  end

  describe 'delegation' do
    it { should delegate(:name).to(:author)   }
    it { should delegate(:name).to('author')  }
    it { should delegate(:name).to(:@author)  }
    it { should delegate(:name).to('@author') }

    it { should_not delegate(:age).to(:author)  }
    it { should_not delegate(:age).to(:@author) }

    it { should delegate(:name).to(:author).with_prefix           }
    it { should delegate(:name).to(:author).with_prefix(:writer)  }
    it { should delegate(:name).to(:author).with_prefix('writer') }

    it { should delegate(:name).to(:author).via(:writer)   }
    it { should delegate(:name).to(:author).via('writer')  }

    it { should delegate(:name_with_salutation).to(:author).with('Ms.')   }
    it { should delegate(:full_name).to(:author).with('Ms.', 'Phd')   }
  end

  describe 'allow_nil' do
    context 'when delegator does allow nil'

    context 'when delegator does not check that delegate is nil' do
      it { should     delegate(:name).to(:author).allow_nil(false) }
      it { should_not delegate(:name).to(:author).allow_nil(true) }
      it { should_not delegate(:name).to(:author).allow_nil }

      it { should     delegate(:name).to(:@author).allow_nil(false) }
      it { should_not delegate(:name).to(:@author).allow_nil(true) }
      it { should_not delegate(:name).to(:@author).allow_nil }
    end

    context 'when delegator does check that delegate is nil' do
      before { post.author = nil }
      it { should_not     delegate(:name2).to(:@author).allow_nil(false) }
      it { should delegate(:name2).to(:@author).allow_nil(true) }
      it { should delegate(:name2).to(:@author).allow_nil }
    end
  end

  describe 'should raise error' do
    it 'with "to" not specified' do
      expect { should delegate(:name) }.to raise_error do |error|
        expect(error.message).to match /need to provide a "to"/
      end
    end

    it 'with an invalid "to"' do
      expect { should delegate(:name).to(:invalid_delegate) }.to raise_error do |error|
        expect(error.message).to match /does not respond to invalid_delegate/
      end
    end

    it 'with both "prefix" and "via"' do
      expect { should delegate(:name).to(:author).with_prefix.via('writer') }.to raise_error do |error|
        expect(error.message).to match /cannot specify delegate using "with_prefix" and "via"/
      end
    end

    it 'with delegate that requires arguments' do
      expect { should delegate(:name).to(:name_with_salutation) }.to raise_error do |error|
        expect(error.message).to match /name_with_salutation method does not have zero or -1 arity/
      end
    end

    it 'with delegate method argument mismatch' do
      expect { should delegate(:name_with_salutation).to(:author) }.to raise_error do |error|
        expect(error.message).to match /wrong number of arguments/
      end
    end
  end

  describe 'messages' do
    let(:matcher) { self.class.parent_groups[1].description }
    subject       { eval matcher }
    before        { subject.matches? post }

    context('delegate(:name).to(:author)') do
      its(:description)                  { should eq 'delegate name to its author' }
      its(:failure_message)              { should match /expected .* to delegate name to its author/ }
      its(:failure_message_when_negated) { should match /expected .* not to delegate name to its author/ }
    end

    context('delegate(:name).to(:@author)') do
      its(:description)                  { should eq 'delegate name to its @author' }
      its(:failure_message)              { should match /expected .* to delegate name to its @author/ }
      its(:failure_message_when_negated) { should match /expected .* not to delegate name to its @author/ }
    end

    context('delegate(:name).to(:author).with_prefix') do
      its(:description)                  { should eq 'delegate name to its author with prefix author' }
      its(:failure_message)              { should match /expected .* to delegate name to its author with prefix author/ }
      its(:failure_message_when_negated) { should match /expected .* not to delegate name to its author with prefix author/ }
    end

    context('delegate(:name).to(:author).with_prefix("writer")') do
      its(:description)                  { should eq 'delegate name to its author with prefix writer' }
      its(:failure_message)              { should match /expected .* to delegate name to its author with prefix writer/ }
      its(:failure_message_when_negated) { should match /expected .* not to delegate name to its author with prefix writer/ }
    end

    context('delegate(:name).to(:author).via("writer")') do
      its(:description)                  { should eq 'delegate name to its author via writer' }
      its(:failure_message)              { should match /expected .* to delegate name to its author via writer/ }
      its(:failure_message_when_negated) { should match /expected .* not to delegate name to its author via writer/ }
    end

    context('delegate(:name_with_salutation).to(:author).with("Ms.")') do
      its(:description)                  { should eq 'delegate name_with_salutation with arguments Ms. to its author' }
      its(:failure_message)              { should match /expected .* to delegate name_with_salutation with arguments Ms. to its author/ }
      its(:failure_message_when_negated) { should match /expected .* not to delegate name_with_salutation with arguments Ms. to its author/ }
    end

    context('delegate(:full_name).to(:author).with("Ms.", "Phd")') do
      its(:description)                  { should eq 'delegate full_name with arguments Ms., Phd to its author' }
      its(:failure_message)              { should match /expected .* to delegate full_name with arguments Ms., Phd to its author/ }
      its(:failure_message_when_negated) { should match /expected .* not to delegate full_name with arguments Ms., Phd to its author/ }
    end
  end
end
