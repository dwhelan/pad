require 'spec_helper'

describe 'Version' do
  before { load './lib/pad/version.rb' }

  it('should be present') { expect(Pad::VERSION).to_not be_empty }
end
