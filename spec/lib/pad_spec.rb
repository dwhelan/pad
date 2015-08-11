require 'spec_helper'

require_relative 'model_context'

module Pad
  shared_examples 'delegate build to' do |builder, builder_options={}|
    block   = Proc.new {}
    options = builder_options.merge(foo: :bar)

    shared_examples 'delegate' do |delegate, method, args, block|

    end
    [:model, :entity].each do |method|

      describe "Pad.#{method}" do

        context 'with no options and no block' do
          it "should call #{builder}.#{method}({}) with no block" do
            expect(builder).to receive(method) do |passed_options, &passed_block|
              expect(passed_options).to eql Hash.new
              expect(passed_block).to be_nil
            end

            Pad.send(method, builder_options.dup)
          end
        end

        context 'with options only' do
          it "should call #{builder}.#{method}(#{options}) with no block" do
            expect(builder).to receive(method) do |passed_options, &passed_block|
              expect(passed_options).to eql foo: :bar
              expect(passed_block).to be_nil
            end

            Pad.send(method, options.dup)
          end
        end

        context 'with block only' do
          it "should call #{builder}.#{method}({}) with the block" do
            expect(builder).to receive(method) do |passed_options, &passed_block|
              expect(passed_options).to eql Hash.new
              expect(passed_block).to be block
            end

            Pad.send(method, builder_options.dup, &block)
          end
        end

        context 'with options and block' do
          it "should call #{builder}.#{method}(#{options}) with the block" do
            expect(builder).to receive(method) do |passed_options, &passed_block|
              expect(passed_options).to eql foo: :bar
              expect(passed_block).to be block
            end

            include Pad.send(method, options.dup, &block)
          end
        end
      end
    end
  end

  context 'with default builder' do
    include_examples 'delegate build to', Pad::Virtus
  end

  builder = Class.new {def to_s; 'builder' end}.new

  context 'with global configured builder' do
    before { Pad.config.builder = builder }
    after  { Pad.reset }

    include_examples 'delegate build to', builder
  end

  context 'with builder specified in options' do
    include_examples 'delegate build to', builder, builder: builder
  end
end
