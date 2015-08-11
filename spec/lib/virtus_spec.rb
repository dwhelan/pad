require 'spec_helper'
# require 'shoulda/matchers/independent/delegate_method_matcher'
require 'shoulda/matchers'

class String
  def squish
    self
  end
end

module Pad
  describe Virtus do

    describe 'Virtus.entity' do
      include_examples 'entity module', Virtus.entity
    end

    shared_examples 'delegate Virtus build' do |method, builder|
      block   = Proc.new {}
      options = { foo: :bar }

      describe "Virtus.#{method}" do

        context 'with no options block and no block' do
          # it { expect(Virtus).to delegate_method(:model).as(:call) }
          it "should call #{builder}.call({}) with no block" do
            expect(builder).to receive(:call) do |passed_options, &passed_block|
              expect(passed_options).to eql Hash.new
              expect(passed_block).to be_nil
              Module.new
            end

            Virtus.send(method)
          end
        end

        context 'with options only' do
          it "should call #{builder}.call(options) with no block" do
            expect(builder).to receive(:call) do |passed_options, &passed_block|
              expect(passed_options).to eql options
              expect(passed_block).to be_nil
              Module.new
            end

            Virtus.send(method, options)
          end
        end

        context 'with block only' do
          it "should call #{builder}.call({}) with the block" do
            expect(builder).to receive(:call) do |passed_options, &passed_block|
              expect(passed_options).to eql Hash.new
              expect(passed_block).to be block
              Module.new
            end

            Virtus.send(method, {}, &block)
          end
        end

        context 'with options and block' do
          it "should call #{builder}.call(options) with the block" do
            expect(builder).to receive(:call) do |passed_options, &passed_block|
              expect(passed_options).to eql options
              expect(passed_block).to be block
              Module.new
            end

            Virtus.send(method, options, &block)
          end
        end
      end
    end

    include_examples 'delegate Virtus build', :model,  Pad::Virtus::ModelBuilder
    include_examples 'delegate Virtus build', :entity, Pad::Virtus::EntityBuilder
  end
end
