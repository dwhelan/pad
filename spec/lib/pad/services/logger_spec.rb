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
        before do
          allow(logger1).to receive(:<<).with('message') { 7 }
          allow(logger2).to receive(:<<).with('message') { 7 }
        end

        it 'should delgate' do
          expect(logger1).to receive(:<<).with('message')
          expect(logger2).to receive(:<<).with('message')
          subject << 'message'
        end

        it 'return the total characters written' do
          expect(subject << 'message').to eq 14
        end
      end
    end
  end
end
