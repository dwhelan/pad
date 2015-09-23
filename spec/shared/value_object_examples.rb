module Pad
  shared_examples_for 'a value object builder' do
    include_examples 'a value object module', described_class.value_object
  end

  shared_examples 'a value object module' do |mod|
    include_examples 'attribute examples', mod

    let(:klass) { Class.new { include mod } }
    subject     { klass.new }

    describe 'default visibility' do
      subject { klass.new }

      before do
        klass.class_eval do
          attribute :default
        end
      end

      it { is_expected.to have_attribute(:default).with_reader(:public).with_writer(:private) }
    end
  end
end
