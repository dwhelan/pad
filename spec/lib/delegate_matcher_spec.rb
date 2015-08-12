require 'spec_helper'

describe 'Delegate matcher' do
  let(:post) do
    Class.new do
      attr_accessor :author
    end.new
  end

  let(:author) do
    Class.new do
      def name
      end
    end.new
  end

  context 'simple delegation' do
    context 'to attribute' do
      it 'with no prefix should call same method' do
        post.class.class_eval do
          def name
            @author.name
          end
        end
        expect(post).to delegate(:name).to(:@author)
      end
    end

    context 'to method' do

      it 'with no prefix should call same method' do
        post.class.class_eval do
          def name
            author.name
          end
        end
        expect(post).to delegate(:name).to(:author)
      end

      it 'with unspecified prefix should call method with prefix of delegate name' do
        post.class.class_eval do
          def author_name
            author.name
          end
        end
        expect(post).to delegate(:name).to(:author).with_prefix
      end

      it 'with specified prefix should call method with prefix ' do
        post.class.class_eval do
          def writer_name
            author.name
          end
        end
        expect(post).to delegate(:name).to(:author).with_prefix(:writer)
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
end
