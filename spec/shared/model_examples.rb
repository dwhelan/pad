module Pad
  shared_examples_for 'a model builder' do
    include_examples 'a model module', described_class.model
  end

  shared_examples 'a model module' do |mod|
    include_examples 'attribute examples', mod

    let(:klass) { Class.new { include mod } }
    subject     { klass.new }

    describe 'default visibility' do
      before do
        klass.class_eval do
          attribute :default
        end
      end

      it { is_expected.to have_attribute(:default).with_reader(:public).with_writer(:public) }
    end
  end
end
