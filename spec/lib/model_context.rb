require 'rspec'
require 'pad'

module Pad

  # shared_examples 'a Virtus.model' do |method|
  #   context 'with no block' do
  #
  #     it 'and no options' do
  #       expect(Virtus).to receive(:model) do |options, &passed_block|
  #         expect(options).to eql Hash.new
  #         expect(passed_block).to be_nil
  #         Module.new
  #       end
  #
  #       Class.new { include Pad.send(method) }
  #     end
  #
  #     it 'and nil options' do
  #       expect(Virtus).to receive(:model) do |options, &passed_block|
  #         expect(options).to eql Hash.new
  #         expect(passed_block).to be_nil
  #         Module.new
  #       end
  #
  #       Class.new { include Pad.send(method, nil) }
  #     end
  #
  #     it 'with options' do
  #       expect(Virtus).to receive(:model) do |args, &passed_block|
  #         expect(args).to eql(foo: :bar)
  #         expect(passed_block).to be_nil
  #         Module.new
  #       end
  #
  #       Class.new { include Pad.send(method, foo: :bar) }
  #     end
  #   end
  #
  #   context 'with a block' do
  #     block = Proc.new {}
  #
  #     it 'and nil options' do
  #       expect(Virtus).to receive(:model) do |options, &passed_block|
  #         expect(options).to eql Hash.new
  #         expect(passed_block).to be block
  #         Module.new
  #       end
  #
  #       Class.new { include Pad.send(method, nil, &block) }
  #     end
  #
  #     it 'and args' do
  #       expect(Virtus).to receive(:model) do |options, &passed_block|
  #         expect(options).to eql(foo: :bar)
  #         expect(passed_block).to be block
  #         Module.new
  #       end
  #
  #       Class.new { include Pad.send(method, {foo: :bar}, &block) }
  #     end
  #   end
  # end

  shared_examples 'a model builder' do |method, builder|
    it 'with no options or block' do
      expect(builder).to receive(:call) do |options, &passed_block|
        expect(options).to eql Hash.new
        expect(passed_block).to be_nil
        Module.new
      end

      Class.new { include method.call }
    end

    it 'with only options' do
      expect(builder).to receive(:call) do |args, &passed_block|
        expect(args).to eql foo: :bar
        expect(passed_block).to be_nil
        Module.new
      end

      Class.new { include method.call foo: :bar}
    end

    it 'with only a block' do
      expect(builder).to receive(:call) do |options, &passed_block|
        expect(options).to eql Hash.new
        expect(passed_block.call).to eql 'foo'
        Module.new
      end

      Class.new { include method.call { 'foo' } }
    end

    it 'with options and a block' do
      expect(builder).to receive(:call) do |options, &passed_block|
        expect(options).to eql foo: :bar
        expect(passed_block.call).to eql 'foo'
        Module.new
      end

      Class.new { include method.call(foo: :bar) { 'foo' } }
    end
  end
end
