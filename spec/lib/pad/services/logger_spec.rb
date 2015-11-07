require 'spec_helper'

module Pad
  module Services
    describe Logger do
      before do
        @service_classes = Logging.service_classes
        @services        = Logging.services

        Pad::Services::Logging.service_classes = []
        Pad::Services::Logging.services        = []
      end

      describe 'ruby logger' do
        let(:logger) { ::Logger.new(nil) }

        before { Logging.register logger }

        [:debug, :info, :warn, :error, :fatal, :unknown].each do |method|
          describe method.to_s do
            it { expect(subject).to delegate(method).with('message').to(logger).without_return }
            it { expect(subject).to delegate(method).with('message').with_block.to(logger).without_return }
            it { expect(subject).to delegate(method).with.with_block.to(logger).with(nil).without_return }
          end
        end
      end

      describe 'custom logger' do
        before do
          klass = Class.new do
            include Pad::Services::Logging

            [:debug, :info, :warn, :error, :fatal, :unknown].each do |method|
              define_method(method) {|*|}
            end
          end
          klass.new
        end

        let(:logger) { subject.services.first }

        [:debug, :info, :warn, :error, :fatal, :unknown].each do |method|
          describe method.to_s do
            it { expect(subject).to delegate(method).with('message').to(logger).without_return }
            it { expect(subject).to delegate(method).with('message').with_block.to(logger).without_return }
            it { expect(subject).to delegate(method).with.with_block.to(logger).with(nil).without_return }
          end
        end
      end

      after do
        Pad::Services::Logging.service_classes = @service_classes
        Pad::Services::Logging.services        = @services
      end
    end
  end
end
