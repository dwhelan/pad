module Pad

  shared_examples_for 'a value object builder' do
    include_examples 'a value object module', described_class.value_object
  end

  shared_examples 'a value object module' do |mod|
    include_examples 'a model module', described_class.value_object
  end
end
