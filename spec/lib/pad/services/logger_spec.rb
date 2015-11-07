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
      end
    end

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

        include_examples 'logging service delegation'
      end

      describe 'custom logger' do
        before do
          Class.new do
            include Pad::Services::Logging

            [:debug, :info, :warn, :error, :fatal, :unknown].each do |method|
              define_method(method) { |*| }
            end
          end
        end

        let(:logger) { subject.services.first }

        include_examples 'logging service delegation'
      end

      after do
        Pad::Services::Logging.service_classes = @service_classes
        Pad::Services::Logging.services        = @services
      end
    end
  end
end
