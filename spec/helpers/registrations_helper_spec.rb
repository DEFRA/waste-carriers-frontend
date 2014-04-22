require 'spec_helper'

describe RegistrationsHelper do
  describe "#format_date" do
    specify { helper.format_date('1 Jan 2014'.to_date).should == '1st Jan 2014' }
  end
end