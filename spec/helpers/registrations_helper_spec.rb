require 'spec_helper'

describe RegistrationsHelper do
  describe "#format_date" do
    specify { helper.format_date('1 Jan 2014'.to_date).should == 'Wednesday 1st January 2014' }
    specify { helper.format_date('2 Jan 2014'.to_date).should == 'Thursday 2nd January 2014' }
    specify { helper.format_date('3 Jan 2014'.to_date).should == 'Friday 3th January 2014' }
    specify { helper.format_date('4 Jan 2014'.to_date).should == 'Saturday 4th January 2014' }
    specify { helper.format_date('5 Jan 2014'.to_date).should == 'Sunday 5th January 2014' }
    specify { helper.format_date('6 Jan 2014'.to_date).should == 'Monday 6th January 2014' }
    specify { helper.format_date('7 Jan 2014'.to_date).should == 'Tuesday 7th January 2014' }
    specify { helper.format_date('8 Jan 2014'.to_date).should == 'Wednesday 8th January 2014' }
    specify { helper.format_date('9 Jan 2014'.to_date).should == 'Thursday 9th January 2014' }
    specify { helper.format_date('10 Jan 2014'.to_date).should == 'Friday 10th January 2014' }

    specify { helper.format_date('11 Jan 2014'.to_date).should == 'Saturday 11th January 2014' }
    specify { helper.format_date('12 Jan 2014'.to_date).should == 'Sunday 12th January 2014' }
    specify { helper.format_date('13 Jan 2014'.to_date).should == 'Monday 13th January 2014' }
    specify { helper.format_date('14 Jan 2014'.to_date).should == 'Tuesday 14th January 2014' }
    specify { helper.format_date('15 Jan 2014'.to_date).should == 'Wednesday 15th January 2014' }
    specify { helper.format_date('16 Jan 2014'.to_date).should == 'Thursday 16th January 2014' }
    specify { helper.format_date('17 Jan 2014'.to_date).should == 'Friday 17th January 2014' }
    specify { helper.format_date('18 Jan 2014'.to_date).should == 'Saturday 18th January 2014' }
    specify { helper.format_date('19 Jan 2014'.to_date).should == 'Sunday 19th January 2014' }
    specify { helper.format_date('20 Jan 2014'.to_date).should == 'Monday 20th January 2014' }

    specify { helper.format_date('21 Jan 2014'.to_date).should == 'Tuesday 21st January 2014' }
    specify { helper.format_date('22 Jan 2014'.to_date).should == 'Wednesday 22nd January 2014' }
    specify { helper.format_date('23 Jan 2014'.to_date).should == 'Thursday 23rd January 2014' }
    specify { helper.format_date('24 Jan 2014'.to_date).should == 'Friday 24th January 2014' }
    specify { helper.format_date('25 Jan 2014'.to_date).should == 'Saturday 25th January 2014' }
    specify { helper.format_date('26 Jan 2014'.to_date).should == 'Sunday 26th January 2014' }
    specify { helper.format_date('27 Jan 2014'.to_date).should == 'Monday 27th January 2014' }
    specify { helper.format_date('28 Jan 2014'.to_date).should == 'Tuesday 28th January 2014' }
    specify { helper.format_date('29 Jan 2014'.to_date).should == 'Wednesday 29th January 2014' }
    specify { helper.format_date('30 Jan 2014'.to_date).should == 'Thursday 30th January 2014' }

    specify { helper.format_date('31 Jan 2014'.to_date).should == 'Friday 31st January 2014' }
  end
end