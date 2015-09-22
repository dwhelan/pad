module Pad
  shared_examples_for 'a model builder' do
    include_examples 'a model module', described_class.model
  end

  shared_examples 'a model module' do |mod|
    let(:klass) { Class.new { include mod } }

    describe 'attributes' do
      subject { klass.new }

      before do
        klass.class_eval do
          attribute :thing
          attribute :name, String
          attribute :private_reader, String, reader: :private
        end
      end

      it { is_expected.to have_attribute(:thing) }
      it { is_expected.to have_attribute(:name) }
      it { is_expected.to have_attribute(:private_reader).with_reader(:private) }

      it do
        expect(subject.name).to be_nil
      end

      it do
        subject.name = 'John'
        expect(subject.name).to eq 'John'
      end
    end

    # TODO: add additional model checks: attributes, mass assignment, contructor
    # TODO: add optional features of model
  end
end
