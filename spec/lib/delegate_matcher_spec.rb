# noinspection RubyResolve
require 'spec_helper'
require 'rspec/its'

describe 'Delegate matcher' do
  let(:post) do
    Class.new do
      attr_accessor :author

      def first_name
        author.first_name if author
      end

      def middle_name(initial, &block)
        author.middle_name(initial, &block)
      end

      def last_name(&block)
        author.last_name(&block)
      end

      def name
        author.name
      end

      def author_name
        author.name
      end

      def writer(&block)
        author.name(&block)
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

      def name_with_address(*address)
        author.name_with_address(*address)
      end

      def age
        60
      end

    end.new
  end

  let(:author) do
    Class.new do
      def first_name
        'Catherine'
      end

      def middle_name(initial, &block)
        initial ? "A#{block.call}"  : "Ann#{block.call}"
      end

      def last_name(&block)
        "Asaro#{block.call}"
      end

      def name
        'Catherine Asaro'
      end

      def name_with_salutation(salutation)
        "#{salutation} #{name}"
      end

      def full_name(salutation, credentials)
        "#{name_with_salutation(salutation)}, #{credentials}"
      end

      def name_with_address(*address)
        "#{[name, address].flatten.join(', ')}"
      end
    end.new
  end

  subject { post }
  before  { post.author = author }

  describe 'test support' do
    its(:first_name)  { should eq 'Catherine' }
    its(:name)        { should eq 'Catherine Asaro' }
    its(:author_name) { should eq 'Catherine Asaro' }
    its(:writer)      { should eq 'Catherine Asaro' }
    its(:writer_name) { should eq 'Catherine Asaro' }
    its(:age)         { should eq 60                }

    it { expect(post.middle_name(true)  {' is her middle initial'}).to eq 'A is her middle initial' }
    it { expect(post.middle_name(false) {' is her middle name'}).to    eq 'Ann is her middle name'  }

    it { expect(post.last_name {' is an author'}).to eq 'Asaro is an author' }

    it { expect(post.name_with_salutation('Ms.')).to eq 'Ms. Catherine Asaro' }

    it { expect(post.full_name('Ms.', 'Phd')).to     eq 'Ms. Catherine Asaro, Phd' }

    it { expect(post.name_with_address).to                                eq 'Catherine Asaro' }
    it { expect(post.name_with_address('123 Main St.')).to                eq 'Catherine Asaro, 123 Main St.' }
    it { expect(post.name_with_address('123 Main St.', 'Springfield')).to eq 'Catherine Asaro, 123 Main St., Springfield' }
  end

  describe 'delegation' do
    it { should delegate(:name).to(:author)   }
    it { should delegate(:name).to('author')  }
    it { should delegate(:name).to(:@author)  }
    it { should delegate(:name).to('@author') }

    it { should_not delegate(:age).to(:author)  }
    it { should_not delegate(:age).to(:@author) }
  end

  describe 'with_prefix' do
    it { should delegate(:name).to(:author).with_prefix           }
    it { should delegate(:name).to(:author).with_prefix(:writer)  }
    it { should delegate(:name).to(:author).with_prefix('writer') }
  end

  describe 'with delegate method' do
    it { should delegate(:writer).to('author.name')   }
  end

  describe 'allow_nil' do
    context 'when delegator does not check that delegate is nil' do
      it { should     delegate(:name).to(:author).allow_nil(false) }
      it { should_not delegate(:name).to(:author).allow_nil(true)  }
      it { should_not delegate(:name).to(:author).allow_nil        }

      it { should     delegate(:name).to(:@author).allow_nil(false) }
      it { should_not delegate(:name).to(:@author).allow_nil(true)  }
      it { should_not delegate(:name).to(:@author).allow_nil        }
    end

    context 'when delegator does check that delegate is nil' do
      before { post.author = nil }

      it { should_not delegate(:first_name).to(:author).allow_nil(false) }
      it { should     delegate(:first_name).to(:author).allow_nil(true)  }
      it { should     delegate(:first_name).to(:author).allow_nil        }

      it { should_not delegate(:first_name).to(:@author).allow_nil(false) }
      it { should     delegate(:first_name).to(:@author).allow_nil(true)  }
      it { should     delegate(:first_name).to(:@author).allow_nil        }
    end
  end

  describe 'with arguments' do
    it { should delegate(:name_with_salutation).to(:author).with('Ms.')                      } # single argument
    it { should delegate(:full_name).to(:author).with('Ms.', 'Phd')                          } # multiple arguments
    it { should delegate(:name_with_address).to(:author).with('123 Main St.')                } # optional arguments
    it { should delegate(:name_with_address).to(:author).with('123 Main St.', 'Springfield') } # optional arguments

    it { should delegate(:name_with_salutation).to(:author).with('Ms.').and_pass('Ms')       } # single argument
  end

  describe 'with blocks' do
    it { should     delegate(:last_name).to(:author).with_block       }
    it { should     delegate(:last_name).to(:author).with_a_block       }
    it { should_not delegate(:last_name).to(:author).without_block    }
    it { should_not delegate(:last_name).to(:author).without_a_block    }

    it { should_not delegate(:name).to(:author).with_block            }
    it { should     delegate(:name).to(:author).without_block         }
  end

  describe 'arguments and blocks' do
    it { should delegate(:middle_name).to(:author).with(true).with_block }
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

    context 'delegate(:name).to(:author).allow_nil' do
      its(:description) { should eq 'delegate name to author.name with nil allowed' }
    end

    context 'delegate(:name).to(:author).allow_nil(true)' do
      its(:description) { should eq 'delegate name to author.name with nil allowed' }
    end

    context 'delegate(:name).to(:author).allow_nil(false)' do
      its(:description) { should eq 'delegate name to author.name with nil not allowed' }
    end

    context 'with arguments' do
      context 'delegate(:name_with_salutation).to(:author).with("Ms.")' do
        its(:description) { should eq 'delegate name_with_salutation(Ms.) to author.name_with_salutation' }
      end

      context 'delegate(:full_name).to(:author).with("Ms.", "Phd")' do
        its(:description) { should eq 'delegate full_name(Ms., Phd) to author.full_name' }
      end
    end

    context 'with blocks' do
      context 'delegate(:name).to(:author).with_a_block' do
        its(:description)                  { should eq 'delegate name to author.name with a block' }
        its(:failure_message)              { should match /expected .* to delegate name to author.name with a block but a block was not passed/ }
        its(:failure_message_when_negated) { should match /expected .* not to delegate name to author.name with a block but a block was passed/ }
      end

      context 'delegate(:name).to(:author).without_a_block' do
        its(:description)                  { should eq 'delegate name to author.name without a block' }
        its(:failure_message)              { should match /expected .* to delegate name to author.name without a block but a block was passed/ }
        its(:failure_message_when_negated) { should match /expected .* not to delegate name to author.name without a block but a block was not passed/ }
      end

      context 'delegate(:writer).to("author.name").with_a_block' do
        its(:description)                  { should eq 'delegate writer to author.name with a block' }
      end
    end
  end
end

# error if args not passed correctly to delegate (extra, missing, etc)
# treat arg mismatch as a match failure rather than an exception
# handle default arguments supplied by delegator
