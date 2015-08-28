module Pad

  shared_examples_for 'a value object builder' do
    include_examples 'a value object module', described_class.value_object
  end

  shared_examples 'a value object module' do |mod|
    let(:module_class) { Class.new { include mod } }

    it('should have an "attribute" class method') { expect(module_class).to respond_to :attribute }

    # TODO add additional model checks: attributes, mass assignment, contructor
    # TODO add optional features of model
  end
end
