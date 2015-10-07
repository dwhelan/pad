module Pad
  shared_examples 'attribute examples' do |mod|
    let(:klass) { Class.new { include mod } }
    subject     { klass.new }

    describe 'reader' do
      before do
        klass.class_eval do
          attribute :name
        end
      end

      it { is_expected.to have_attribute(:name).with_reader(:public) }
      it { expect(subject.name).to be_nil }
    end

    describe 'type' do
      before do
        klass.class_eval do
          attribute :name, String, default: ''
        end
      end

      it { is_expected.to have_attribute(:name).of_type(String) }
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
