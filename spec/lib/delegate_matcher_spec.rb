require 'spec_helper'

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
    end.new
  end

  let(:author) do
    Class.new do
      def name
      end
    end.new
  end

  context 'simple delegation' do

    describe 'messages' do

      before  { matcher.matches? post }
      let(:matcher) { eval self.class.description }

      context 'description' do
        subject { matcher.description }

        context('delegate(:name).to(:author)')                       { it { should eq 'delegate name to its author' } }
        context('delegate(:name).to(:@author)')                      { it { should eq 'delegate name to its @author' } }
        context('delegate(:name).to(:author).with_prefix')           { it { should eq 'delegate name to its author with prefix author' } }
        context('delegate(:name).to(:author).with_prefix("writer")') { it { should eq 'delegate name to its author with prefix writer' } }
      end

      context 'failure_message' do
        subject { matcher.failure_message }

        context('delegate(:name).to(:author)')                       { it { should match /expected .* to delegate name to its author/ } }
        context('delegate(:name).to(:@author)')                      { it { should match /expected .* to delegate name to its @author/ } }
        context('delegate(:name).to(:author).with_prefix')           { it { should match /expected .* to delegate name to its author with prefix author/ } }
        context('delegate(:name).to(:author).with_prefix("writer")') { it { should match /expected .* to delegate name to its author with prefix writer/ } }
      end

      context 'failure_message_when_negated' do
        subject { matcher.failure_message_when_negated }

        context('delegate(:name).to(:author)')                       { it { should match /expected .* not to delegate name to its author/ } }
        context('delegate(:name).to(:@author)')                      { it { should match /expected .* not to delegate name to its @author/ } }
        context('delegate(:name).to(:author).with_prefix')           { it { should match /expected .* not to delegate name to its author with prefix author/ } }
        context('delegate(:name).to(:author).with_prefix("writer")') { it { should match /expected .* not to delegate name to its author with prefix writer/ } }
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
      post.class.class_eval do
        def author(salutation)
        end
      end

      expect { expect(post).to delegate(:name).to(:author) }.to raise_error do |exception|
        expect(exception.message).to match /author method does not have zero or -1 arity/
      end
    end
  end
end
