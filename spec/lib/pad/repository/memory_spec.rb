require 'spec_helper'

module Pad
  module Repository
    describe Memory do
      let(:entity) { OpenStruct.new id: 42 }

      describe 'find' do
        it { should respond_to :find }
      end

      describe 'save' do
        it 'should save' do
          subject.save entity
          expect(subject.find 42).to be entity
        end
      end

      describe 'delete' do
        it 'should delete' do
          subject.save entity
          subject.delete entity
          expect(subject.find 42).to be_nil
        end
      end
    end
  end
end
