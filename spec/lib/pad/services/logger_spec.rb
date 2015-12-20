require 'spec_helper'

module Pad
  module Services
    describe Logger do
      let(:logger1) { double('logger1') }
      let(:logger2) { double('logger2') }

      before { subject.register logger1 }
      before { subject.register logger2 }

      [:debug, :info, :warn, :error, :fatal, :unknown].each do |method|
        it "#{method}(message) should be delegated" do
          expect(logger1).to receive(method).with('message')
          expect(logger2).to receive(method).with('message')
          subject.send method, 'message'
        end

        it "#{method}() should be delegated" do
          expect(logger1).to receive(method).with(no_args)
          expect(logger2).to receive(method).with(no_args)
          subject.send method
        end

        it "#{method} should return true if any logger return true" do
          allow(logger1).to receive(method) { true  }
          allow(logger2).to receive(method) { false }
          expect(subject.send(method, 'message')).to be true
        end

        it "#{method} should return false if all loggers return false" do
          allow(logger1).to receive(method) { false }
          allow(logger2).to receive(method) { false }
          expect(subject.send(method, 'message')).to be false
        end

        unless method == :unknown
          it "#{method}? should return true if any logger return true" do
            allow(logger1).to receive("#{method}?") { true  }
            allow(logger2).to receive("#{method}?") { false }
            expect(subject.send("#{method}?")).to be true
          end

          it "#{method}? should return false if all loggers return false" do
            allow(logger1).to receive("#{method}?") { false }
            allow(logger2).to receive("#{method}?") { false }
            expect(subject.send("#{method}?")).to be false
          end
        end
      end

      describe '<<' do
        it 'should be delegated' do
          expect(logger1).to receive(:<<).with('message')
          expect(logger2).to receive(:<<).with('message')
          subject << 'message'
        end

        it 'return the total characters written' do
          allow(logger1).to receive(:<<).with('message') { 7 }
          allow(logger2).to receive(:<<).with('message') { 7 }
          expect(subject << 'message').to eq 14
        end
      end

      describe 'log' do
        it 'should be delegated with only a severity' do
          expect(logger1).to receive(:log).with(::Logger::INFO)
          expect(logger2).to receive(:log).with(::Logger::INFO)
          subject.log ::Logger::INFO
        end

        it 'should be delegated with a message' do
          expect(logger1).to receive(:log).with(::Logger::INFO, 'message')
          expect(logger2).to receive(:log).with(::Logger::INFO, 'message')
          subject.log ::Logger::INFO, 'message'
        end

        it 'should be delegated with a progname' do
          expect(logger1).to receive(:log).with(::Logger::INFO, 'message', 'progname')
          expect(logger2).to receive(:log).with(::Logger::INFO, 'message', 'progname')
          subject.log ::Logger::INFO, 'message', 'progname'
        end

        xit 'should be delegated with a block' do
          block = proc {}
          block2 = proc {}
          expect(logger1).to receive(:log).with(::Logger::INFO, nil, nil).and_yield
          expect(logger2).to receive(:log).with(::Logger::INFO, nil, nil, &block)
          expect(logger1).to receive(:log).with do|severity, message, progname, &block|
            binding.pry
          end
          subject.log ::Logger::INFO, nil, nil, &block2
        end
      end
    end
  end
end
