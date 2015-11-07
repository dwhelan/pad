require 'spec_helper'

module Pad
  module Services
    describe Logging do
      before { @state = Logging.clear }

      let(:service_class) { Class.new { include Logging } }
      let(:service)       { Object.new }

      subject { described_class }

      shared_examples 'nothing should be registered' do
        it { expect(subject.service_classes).to be_empty }
        it { expect(subject.services).to be_empty }
      end

      describe 'initially' do
        include_examples 'nothing should be registered'
      end

      it 'should register service classes' do
        service_class
        expect(subject.service_classes).to include service_class
      end

      it 'should register services' do
        subject.register service
        expect(subject.services).to include service
      end

      describe 'state' do
        before do
          service_class
          subject.register service
        end

        let!(:state) { subject.clear }

        describe 'clear' do
          include_examples 'nothing should be registered'
        end

        describe 'restore' do
          before { subject.restore state }

          it { expect(subject.service_classes).to include service_class }
          it { expect(subject.services).to include service }
        end
      end

      after { Logging.restore(@state) }
    end
  end
end
