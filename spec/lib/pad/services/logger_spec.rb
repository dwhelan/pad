require 'spec_helper'

module Pad
  module Services

    class TestLogger
      include Pad::Services::Logging

      [:debug, :info, :warn, :error, :fatal, :unknown].each do |method|
        define_method(method) do |progname = nil, &block|
        end
      end
    end

    describe Logger do

      let(:logger) { subject.services.first }

      [:debug, :info, :warn, :error, :fatal, :unknown].each do |method|
        describe method.to_s do
          it { expect(subject).to delegate(method).with('message').to(logger).without_return }
          it { expect(subject).to delegate(method).with('message').with_block.to(logger).without_return }
          it { expect(subject).to delegate(method).with().with_block.to(logger).with(nil).without_return }
        end
      end
    end
  end
end
