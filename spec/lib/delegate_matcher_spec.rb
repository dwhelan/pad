require 'spec_helper'
require 'rspec/its'

describe 'Delegate matcher' do
  let(:post) do
    Class.new do
      attr_accessor :author

      def name
        author.name
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

      def author_with_salutation(salutation)
      end

      def age
      end

    end.new
  end

  let(:author) do
    Class.new do
      def name
      end
    end.new
  end

  subject { post }

  describe 'delegation' do
    it { should delegate(:name).to(:author)   }
    it { should delegate(:name).to('author')  }
    it { should delegate(:name).to(:@author)  }
    it { should delegate(:name).to('@author') }

    it { should_not delegate(:age).to(:author) }

    it { should delegate(:name).to(:author).with_prefix           }
    it { should delegate(:name).to(:author).with_prefix(:writer)  }
    it { should delegate(:name).to(:author).with_prefix('writer') }

    it { should delegate(:name).to(:author).via(:writer)   }
    it { should delegate(:name).to(:author).via('writer')  }
    it { should delegate(:name).to(:@author).via('writer') }
  end

  describe 'should raise error' do
    it 'with "to" not specifieid' do
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
      expect { should delegate(:name).to(:author).with_prefix().via('writer') }.to raise_error do |error|
        expect(error.message).to match /cannot specify delegate using "with_prefix" and "via"/
      end
    end

    it 'with arg defined for method' do
      expect { should delegate(:name).to(:author_with_salutation) }.to raise_error do |error|
        expect(error.message).to match /author_with_salutation method does not have zero or -1 arity/
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
  end
end
