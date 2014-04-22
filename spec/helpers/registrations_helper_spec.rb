require 'spec_helper'

describe RegistrationsHelper do
  describe "#format_date" do
    specify { helper.format_date('3 Jan 2014'.to_date).should == 'Friday 3rd January 2014' }
  end
end