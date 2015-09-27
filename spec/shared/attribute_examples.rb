module Pad
  shared_examples 'attribute examples' do |mod|
    let(:klass) { Class.new { include mod } }
    subject     { klass.new }

    describe 'reader' do
      before do
        klass.class_eval do
          attribute :name
          attribute :address, String
        end
      end

      it { is_expected.to have_attribute(:name).with_reader(:public) }
      it { expect(subject.name).to be_nil }

      it { is_expected.to have_attribute(:address) }
    end

    describe 'visibility' do
      before do
        klass.class_eval do
          attribute :private,   String, reader: :private,   writer: :private
          attribute :protected, String, reader: :protected, writer: :protected
          attribute :public,    String, reader: :public,    writer: :public
        end
      end

      it { is_expected.to have_attribute(:private).  with_reader(:private).  with_writer(:private)   }
      it { is_expected.to have_attribute(:protected).with_reader(:protected).with_writer(:protected) }
      it { is_expected.to have_attribute(:public).   with_reader(:public).   with_writer(:public)    }
    end

    # TODO: add checks for mass assignment, constructor
    # TODO: add checks for constructor
    # TODO: add optional features of model
  end
end
