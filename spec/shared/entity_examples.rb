module Pad
  shared_examples_for 'an entity builder' do
    include_examples 'an entity module', described_class.entity
  end

  shared_examples_for 'an entity module' do |mod|
    let(:entity_class) { Class.new { include mod } }
    let(:subclass)     { Class.new(entity_class).new(id: 1) }

    let(:entity0)  { entity_class.new id: nil }
    let(:entity0a) { entity_class.new id: nil }
    let(:entity1)  { entity_class.new id: 1   }
    let(:entity1a) { entity_class.new id: 1   }
    let(:entity2)  { entity_class.new id: 2   }

    it('should have an "id" attribute') { expect(entity1).to have_attributes id: 1 }

    describe 'hash' do
      it('for the same entity id should be equal')       { expect(entity1.hash).to     eq entity1a.hash }
      it('for different entity ids should not be equal') { expect(entity1.hash).not_to eq entity2.hash  }
      it('for different classes should not be equal')    { expect(entity1.hash).not_to eq subclass.hash }
    end

    describe 'equality' do
      context 'with nil id' do
        it 'should be true when compared to self' do
          expect(entity0).to eq  entity0
          expect(entity0).to eql entity0
        end

        it 'should be false when compared to another entity with a nil id' do
          expect(entity0).not_to eq  entity0a
          expect(entity0).not_to eql entity0a
        end
      end

      context 'with the same id' do
        it 'should be true when compared to self' do
          expect(entity1).to eq  entity1
          expect(entity1).to eql entity1
        end

        it 'should be true when compared to another entity with the same id' do
          expect(entity1).to eq  entity1a
          expect(entity1).to eql entity1a
        end
      end

      context 'with a different id' do
        it 'should be true when compared to another entity with a different id' do
          expect(entity1).not_to eq  entity2
          expect(entity1).not_to eql entity2
        end
      end

      context 'with an object of a different class' do
        it 'should be false' do
          expect(entity1).not_to eq  Object.new
          expect(entity1).not_to eql Object.new
        end
      end

      context 'with an object that is a subclass' do
        it 'should be false' do
          expect(entity1).not_to eq  subclass
          expect(entity1).not_to eql subclass
        end
      end

      context 'with an object that is a superclass' do
        it 'should be false' do
          expect(subclass).not_to eq  entity1
          expect(subclass).not_to eql entity1
        end
      end
    end
  end
end

# TODO: Check for options being handled with entity
