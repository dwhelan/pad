module Pad

  shared_examples_for 'entity module' do |entity_module|
    let(:entity_class) { Class.new { include entity_module } }
    let(:subclass)     { Class.new(entity_class).new(id: 1) }

    let(:entity1)  { entity_class.new id: 1   }
    let(:entity1a) { entity_class.new id: 1   }
    let(:entity2)  { entity_class.new id: 2   }

    it('should have an "id" attribute') { expect(entity1).to have_attributes id: 1 }

    describe 'hash' do
      it('for the same entity id should be equal')       { expect(entity1.hash).to eq     entity1a.hash }
      it('for different entity ids should not be equal') { expect(entity1.hash).not_to eq entity2.hash  }
      it('for different classes should not be equal')    { expect(entity1.hash).not_to eq subclass.hash }
    end

    describe 'equality' do
      context 'with nil id' do
        let(:entity0)  { entity_class.new id: nil }
        let(:entity0a) { entity_class.new id: nil }

        it 'should be equal to self' do
          expect(entity0).to eq  entity0
          expect(entity0).to eql entity0
        end

        it 'should not be equal to another entity with a nil id' do
          expect(entity0).not_to eq  entity0a
          expect(entity0).not_to eql entity0a
        end
      end

      context 'with a non-nil id' do
        it 'should be equal to self' do
          expect(entity1).to eq  entity1
          expect(entity1).to eql entity1
        end

        it 'should be equal to an entity of the same class with the same id' do
          expect(entity1).to eq  entity1a
          expect(entity1).to eql entity1a
        end

        it 'should not be equal to an entity of the same class with a different id' do
          expect(entity1).not_to eq  entity2
          expect(entity1).not_to eql entity2
        end

        it 'should not be equal to an object of a different class' do
          expect(entity1).not_to eq  Object.new
          expect(entity1).not_to eql Object.new
        end

        it 'should not be equal to an instance of a subclass' do
          expect(entity1).not_to eq  subclass
          expect(entity1).not_to eql subclass
        end

        it 'should not be equal to an instance of a superclass' do
          expect(subclass).not_to eq  entity1
          expect(subclass).not_to eql entity1
        end
      end
    end
  end
end
