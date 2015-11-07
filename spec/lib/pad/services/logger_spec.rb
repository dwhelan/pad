require 'spec_helper'

module Pad
  module Services
    shared_examples 'logging service delegation' do
      [:debug, :info, :warn, :error, :fatal, :unknown].each do |method|
        describe method.to_s do
          it { expect(subject).to delegate(method).with('message').to(logger).without_return }
          it { expect(subject).to delegate(method).with('message').with_block.to(logger).without_return }
          it { expect(subject).to delegate(method).with.with_block.to(logger).with(nil).without_return }
        end

        unless method == :unknown
          describe "#{method}?" do
            it { expect(subject).to delegate("#{method}?").to(logger).without_return }
            it { expect(subject.public_send "#{method}?").to be true }
          end
        end
      end
    end

    describe Logger do
      before { @state = Logging.clear }

      describe 'ruby logger' do
        let(:logger) { ::Logger.new(nil) }

        before { Logging.register logger }

        include_examples 'logging service delegation'
      end

      describe 'custom logger' do
        before do
          Class.new do
            include Logging

            [:debug, :info, :warn, :error, :fatal, :unknown].each do |method|
              define_method(method)       { |*| }
              define_method("#{method}?") { true } unless method == :unknown
            end
          end
        end

        let(:logger) { subject.services.first }

        include_examples 'logging service delegation'
      end

      after { Logging.restore @state }
    end
  end
end
