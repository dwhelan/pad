module Pad

  shared_examples_for 'a model builder' do
    include_examples 'a model module', described_class.model
  end

  shared_examples 'a model module' do |mod|
    let(:klass) { Class.new { include mod } }

    describe '"attribute" class method' do
      subject { klass.method 'attribute' }

      it          { should_not be_nil }
      its(:arity) { should eq -2      }
    end

    # TODO add additional model checks: attributes, mass assignment, contructor
    # TODO add optional features of model
  end
end
