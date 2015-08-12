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

      def writer_name
        author.name
      end

      def author_with_salutation(salutation)
      end

    end.new
  end

  let(:author) do
    Class.new do
      def name
      end
    end.new
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
  end

  it 'with no prefix should call same method' do
    expect(post).to delegate(:name).to(:author)
    expect(post).to delegate(:name).to(:@author)
  end

  it 'with unspecified prefix should call method with prefix of delegate name' do
    expect(post).to delegate(:name).to(:author).with_prefix
    expect(post).to delegate(:name).to(:@author).with_prefix
  end

  it 'with specified prefix should call method with prefix ' do
    expect(post).to delegate(:name).to(:author).with_prefix(:writer)
    expect(post).to delegate(:name).to(:@author).with_prefix(:writer)
  end

  it 'with an invalid "to" should raise' do
    expect { expect(post).to delegate(:name).to(:invalid_delegate) }.to raise_error do |exception|
      expect(exception.message).to match /does not respond to invalid_delegate/
    end
  end

  it 'with arg defined for method should raise' do
    expect { expect(post).to delegate(:name).to(:author_with_salutation) }.to raise_error do |exception|
      expect(exception.message).to match /author_with_salutation method does not have zero or -1 arity/
    end
  end
end
