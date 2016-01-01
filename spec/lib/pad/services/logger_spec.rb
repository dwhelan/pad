require 'spec_helper'

module Pad
  module Services
    describe Logger do
      let(:logger1) { double('logger1') }
      let(:logger2) { double('logger2') }
      let(:loggers) { [logger1, logger2] }

      before { subject.register logger1, logger2 }

      [:debug, :info, :warn, :error, :fatal, :unknown].each do |method|
        before do
          allow(logger1).to receive(method) { true }
          allow(logger2).to receive(method) { true }
        end

        it "#{method} should be delegated with a message" do
          expect(subject).to delegate(method).to(*loggers).with('message').and_return true
        end

        it "#{method} should be delegated without a message" do
          expect(subject).to delegate(method).to(*loggers).and_return true
        end

        it "#{method} should be delegated with a block" do
          expect(subject).to delegate(method).to(*loggers).with_block.and_return true
        end

        it "#{method} should return true if any logger returns true" do
          allow(logger1).to receive(method) { true  }
          allow(logger2).to receive(method) { false }
          expect(subject.send(method, 'message')).to be true
        end

        it "#{method} should return false if all loggers return false" do
          allow(logger1).to receive(method) { false }
          allow(logger2).to receive(method) { false }
          expect(subject.send(method, 'message')).to be false
        end

        next if method == :unknown

        it "#{method}? should return true if any logger return true" do
          allow(logger1).to receive("#{method}?") { true  }
          allow(logger2).to receive("#{method}?") { false }
          expect(subject).to delegate("#{method}?").to(*loggers).and_return true
        end

        it "#{method}? should return false if all loggers return false" do
          allow(logger1).to receive("#{method}?") { false }
          allow(logger2).to receive("#{method}?") { false }
          expect(subject).to delegate("#{method}?").to(*loggers).and_return false
        end
      end

      it '<< should be delegated' do
        allow(logger1).to receive(:<<) { 7 }
        allow(logger2).to receive(:<<) { 35 }
        expect(subject).to delegate(:<<).with('message').to(*loggers).and_return 7
      end

      [:add, :log].each do |method|
        describe "#{method}" do
          before do
            allow(logger1).to receive(method) { false }
            allow(logger2).to receive(method) { false }
          end

          it { should delegate(method).with(::Logger::INFO).to(*loggers).with_block.and_return false }
          it { should delegate(method).with(::Logger::INFO, 'message').to(*loggers).and_return false }
          it { should delegate(method).with(::Logger::INFO, 'message', 'progname').to(*loggers).and_return false }
        end
      end
    end
  end
end
