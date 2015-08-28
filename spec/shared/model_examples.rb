module Pad

  shared_examples_for 'a model builder' do
    include_examples 'a model module', described_class.model
  end

  shared_examples 'a model module' do |mod|
    let(:module_class) { Class.new { include mod } }

    it('should have an "attribute" class method') { expect(module_class).to respond_to :attribute }

    # TODO add additional model checks: attributes, mass assignment, contructor
    # TODO add optional features of model
  end
end
