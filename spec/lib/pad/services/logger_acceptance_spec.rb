require 'spec_helper'

module Pad
  module Services
    describe Logger do
      specify 'should log to console' do
        subject.register ::Logger.new(STDOUT)
        expect { subject.info 'test' }.to output(/^I.*INFO.*test$/).to_stdout_from_any_process
      end
    end
  end
end
