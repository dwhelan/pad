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

      def name_with_nil_check
        author.name_with_nil_check if author
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

      def name_with_arg(arg)
        author.name_with_arg(arg)
      end

      def name_with_multiple_args(arg1, arg2)
        author.name_with_multiple_args(arg1, arg2)
      end

      def name_with_optional_args(*address)
        author.name_with_optional_args(*address)
      end

      def name_with_block(&block)
        author.name_with_block(&block)
      end

      def name_with_different_block(&block)
        author.name_with_different_block(&Proc.new{})
      end

      def name_with_arg_and_block(arg, &block)
        author.name_with_arg_and_block(arg, &block)
      end

      def name_with_different_arg_and_block(arg, &block)
        author.name_with_different_arg_and_block('Miss', &Proc.new{})
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

      def name_with_nil_check
        name
      end

      def name_with_arg(arg)
        "#{arg} #{name}"
      end

      def name_with_multiple_args(arg1, arg2)
        "#{arg1} #{arg2} #{name}"
      end

      def name_with_optional_args(*args)
        "#{[args, name].flatten.join(' ')}"
      end

      def name_with_block(&block)
        "#{block.call} #{name}"
      end

      def name_with_arg_and_block(arg, &block)
        "#{arg} #{block.call} #{name}"
      end

      def name_with_different_arg_and_block(arg, &block)
        "#{arg} #{block.call} #{name}"
      end
    end.new
  end

  subject { post }
  before  { post.author = author }

  describe 'test support' do
    its(:name_with_nil_check) { should eq 'Catherine Asaro' }
    its(:name)                { should eq 'Catherine Asaro' }
    its(:author_name)         { should eq 'Catherine Asaro' }
    its(:writer)              { should eq 'Catherine Asaro' }
    its(:writer_name)         { should eq 'Catherine Asaro' }
    its(:age)                 { should eq 60                }

    it { expect(post.name_with_arg('The author')).to               eq 'The author Catherine Asaro' }
    it { expect(post.name_with_multiple_args('The', 'author')).to  eq 'The author Catherine Asaro' }
    it { expect(post.name_with_optional_args).to                   eq 'Catherine Asaro' }
    it { expect(post.name_with_optional_args('The author')).to     eq 'The author Catherine Asaro' }
    it { expect(post.name_with_optional_args('The', 'author')).to  eq 'The author Catherine Asaro' }
    it { expect(post.name_with_block{'The author'}).to             eq 'The author Catherine Asaro' }
    it { expect(post.name_with_arg_and_block('The'){'author'} ).to eq 'The author Catherine Asaro' }
  end

  describe 'delegation' do
    [:author,  'author',  :'author.name',  'author.name',
     :@author, '@author', :'@author.name', '@author.name'].each do |delegate|
      it { should     delegate(:name).to(delegate)   }
      it { should_not delegate(:age).to(delegate) }
    end
  end

  describe 'with_prefix' do
    it { should delegate(:name).to(:author).with_prefix           }
    it { should delegate(:name).to(:author).with_prefix(:writer)  }
    it { should delegate(:name).to(:author).with_prefix('writer') }
  end

  describe 'with delegate method' do
    it { should delegate(:writer).to('author.name')   }
    it { should delegate(:writer).to(:'author.name')  }
    it { should delegate(:writer).to('@author.name')  }
    it { should delegate(:writer).to(:'@author.name') }
  end

  describe 'allow_nil' do
    context 'when delegator checks that delegate is nil' do
      before { post.author = nil }

      it { should_not delegate(:name_with_nil_check).to(:author).allow_nil(false) }
      it { should     delegate(:name_with_nil_check).to(:author).allow_nil(true)  }
      it { should     delegate(:name_with_nil_check).to(:author).allow_nil        }
    end

    context 'when delegator does not check that delegate is nil' do
      it { should     delegate(:name).to(:author).allow_nil(false) }
      it { should_not delegate(:name).to(:author).allow_nil(true)  }
      it { should_not delegate(:name).to(:author).allow_nil        }
    end
  end

  describe 'with arguments' do
    it { should delegate(:name_with_arg).with('Ms.').to(:author)                                     }
    it { should delegate(:name_with_multiple_args).with('Ms.', 'Phd').to(:author)                    }
    it { should delegate(:name_with_optional_args).with('123 Main St.').to(:author)                  }
    it { should delegate(:name_with_optional_args).with('123 Main St.', 'Springfield').to(:author)   }

    it { should     delegate(:name_with_different_arg_and_block).with('Ms.').to(:author).with('Miss') }
    it { should_not delegate(:name_with_different_arg_and_block).with('Ms.').to(:author).with('Ms.')  }
  end

  describe 'with a block' do
    it { should delegate(:name_with_block).to(:author).with_a_block }
    it { should delegate(:name_with_block).to(:author).with_block   }

    it { should_not delegate(:name).to(:author).with_a_block }
    it { should_not delegate(:name).to(:author).with_block   }
    it { should_not delegate(:name_with_different_block).to(:author).with_a_block }
  end

  describe 'without a block' do
    it { should delegate(:name).to(:author).without_a_block }

    it { should_not delegate(:name_with_block).to(:author).without_block   }
    it { should_not delegate(:name_with_block).to(:author).without_a_block }
    it { should_not delegate(:name_with_different_block).to(:author).without_a_block }
  end

  describe 'arguments and blocks' do
    it { should delegate(:name_with_arg_and_block).to(:author).with(true).with_block }
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

    it 'with delegate that requires arguments' do
      expect { should delegate(:name).to(:name_with_arg) }.to raise_error do |error|
        expect(error.message).to match /name_with_arg method does not have zero or -1 arity/
      end
    end

    it 'with delegate method argument mismatch' do
      expect { should delegate(:name_with_arg).to(:author) }.to raise_error do |error|
        expect(error.message).to match /wrong number of arguments/
      end
    end
  end

  describe 'description' do
    let(:matcher) { self.class.parent_groups[1].description }
    subject       { eval matcher }
    before        { subject.matches? post }

    context 'delegate(:name).to(:author)' do
      its(:description)                  { should eq 'delegate name to author.name' }
      its(:failure_message)              { should match /expected .* to delegate name to author.name/ }
      its(:failure_message_when_negated) { should match /expected .* not to delegate name to author.name/ }
    end

    context 'delegate(:name).to(:@author)' do
      its(:description) { should eq 'delegate name to @author.name' }
    end

    context 'delegate(:name).to(:author).with_prefix' do
      its(:description) { should eq 'delegate author_name to author.name' }
    end

    context 'delegate(:name).to(:author).with_prefix("writer")' do
      its(:description) { should eq 'delegate writer_name to author.name' }
    end

    context 'with allow_nil true' do
      context 'delegate(:name).to(:author).allow_nil' do
        its(:description)     { should eq 'delegate name to author.name with nil allowed' }
        its(:failure_message) { should match /but author was not allowed to be nil/ }
      end

      context 'delegate(:name).to(:author).allow_nil(true)' do
        its(:description)     { should eq 'delegate name to author.name with nil allowed' }
        its(:failure_message) { should match /but author was not allowed to be nil/ }
      end

      context 'delegate(:name_with_nil_check).to(:author).allow_nil' do
        its(:failure_message_when_negated) { should match /but author was allowed to be nil/ }
      end
    end

    context 'with allow_nil false' do
      context 'delegate(:name_with_nil_check).to(:author).allow_nil(false)' do
        its(:description)     { should eq 'delegate name_with_nil_check to author.name_with_nil_check with nil not allowed' }
        its(:failure_message) { should match /but author was allowed to be nil/ }
      end

      context 'delegate(:name).to(:author).allow_nil(false)' do
        its(:failure_message_when_negated) { should match /but author was not allowed to be nil/ }
      end
    end

    context 'with arguments' do
      context 'delegate(:name_with_different_arg_and_block).with("Ms.").to(:author)' do
        its(:description)     { should eq 'delegate name_with_different_arg_and_block("Ms.") to author.name_with_different_arg_and_block("Ms.")' }
        its(:failure_message) { should match /but was called with \("Miss"\)/ }
      end

      context 'delegate(:name_with_different_arg_and_block).with("Ms.").to(:author).with("Miss")' do
        its(:description)                  { should eq 'delegate name_with_different_arg_and_block("Ms.") to author.name_with_different_arg_and_block("Miss")' }
        its(:failure_message_when_negated) { should match /but was called with \("Miss"\)/ }
      end

      context 'delegate(:name_with_multiple_args).with("Ms.", "Phd").to(:author)' do
        its(:description) { should eq 'delegate name_with_multiple_args("Ms.", "Phd") to author.name_with_multiple_args("Ms.", "Phd")' }
      end
    end

    context 'with a block' do
      context 'delegate(:name).to(:author).with_a_block' do
        its(:description)     { should eq 'delegate name to author.name with a block' }
        its(:failure_message) { should match /but a block was not passed/ }
      end

      context 'delegate(:name_with_different_block).to(:author).with_a_block' do
        its(:failure_message) { should match /but a different block .+ was passed/ }
      end

      context 'delegate(:name_with_block).to(:author).with_a_block' do
        its(:failure_message_when_negated) { should match /but a block was passed/ }
      end

      context 'and arguments' do
        context 'delegate(:name_with_different_arg_and_block).with("Ms.").to(:author).with_a_block' do
          its(:description)     { should eq 'delegate name_with_different_arg_and_block("Ms.") to author.name_with_different_arg_and_block("Ms.") with a block' }
          its(:failure_message) { should match /but was called with \("Miss"\) / }
          its(:failure_message) { should match /and a different block .+ was passed/ }
        end

        context 'delegate(:name_with_arg_and_block).to(:author).with(true).with_block' do
          its(:failure_message_when_negated) { should match /but was called with \(true\) / }
          its(:failure_message_when_negated) { should match /and a block was passed/ }
        end
      end
    end

    context 'without a block' do
      context 'delegate(:name).to(:author).without_a_block' do
        its(:description)     { should eq 'delegate name to author.name without a block' }
        its(:failure_message) { should match /but a block was passed/ }
      end

      context 'delegate(:name_with_different_block).to(:author).without_a_block' do
        its(:failure_message) { should match /but a block was passed/ }
      end

      context 'delegate(:name).to(:author).without_a_block' do
        its(:failure_message_when_negated) { should match /but a block was not passed/ }
      end

      context 'and arguments' do
        context 'delegate(:name_with_different_arg_and_block).to(:author).with("Miss").without_a_block' do
          its(:description)     { should eq 'delegate name_with_different_arg_and_block("Miss") to author.name_with_different_arg_and_block("Miss") without a block' }
          its(:failure_message) { should match /but a block was passed/ }
        end

        context 'delegate(:name_with_arg).to(:author).with("Miss").without_a_block' do
          its(:failure_message_when_negated) { should match /but was called with \("Miss"\) / }
          its(:failure_message_when_negated) { should match /and a block was not passed/ }
        end
      end
    end
  end
end

# only print delegated method if method name different from delegator
# review nil check logic
# handle default arguments supplied by delegator
# works with rails delegator
# works with regular ruby delegator
