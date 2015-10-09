module Pad
  shared_examples_for 'a value object builder' do
    include_examples 'a value object module', described_class.value_object
  end

  shared_examples 'a value object module' do |mod|
    include_examples 'attribute examples', mod

    subject { klass.new }

    let(:klass) do
      Class.new do
        include mod

        values do
          attribute :name
        end

        attribute :age
      end
    end

    describe 'default visibility' do
      it { is_expected.to have_attribute(:name).with_reader(:public).with_writer(:private) }
    end

    describe 'equality' do
      specify 'with value attributes all nil' do
        joe1 = klass.new
        joe2 = klass.new
        expect(joe1).to eq joe2
      end

      specify 'with value attributes having same values' do
        joe1 = klass.new name: 'Joe'
        joe2 = klass.new name: 'Joe'
        expect(joe1).to eq joe2
      end

      specify 'with non-value attributes having different values' do
        joe1 = klass.new age: 22
        joe2 = klass.new age: 99
        expect(joe1).to eq joe2
      end

      specify 'with value attributes having different values' do
        joe  = klass.new name: 'Joe'
        jane = klass.new name: 'Jane'
        expect(jane).to_not eq joe
      end
    end
  end
end
