require 'spec_helper'

describe RegistrationsHelper do
  describe "#format_date" do
    specify { helper.format_date('1 Jan 2014'.to_date).should == 'Wednesday 1st January 2014' }
    specify { helper.format_date('2 Jan 2014'.to_date).should == 'Thursday 2nd January 2014' }
    specify { helper.format_date('3 Jan 2014'.to_date).should == 'Friday 3rd January 2014' }
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

  describe '#one_full_message_per_invalid_attribute' do
    context 'multiple errors on base' do
      before do
        @registration = Registration.ctor
        @registration.errors[:base] << 'Error 1' << 'Error 2'
      end

      it 'should have both base errors' do
        helper.one_full_message_per_invalid_attribute(@registration).should == ['Error 1', 'Error 2']
      end
    end

    context 'multiple errors on one attibute' do
      before do
        @registration = Registration.ctor
        @registration.errors[:first_name] << 'too short' << 'too common'
      end

      it 'should have first error' do
        helper.one_full_message_per_invalid_attribute(@registration).should == ['First name too short']
      end
    end

    context 'multiple errors on two attributes and base' do
      before do
        @registration = Registration.ctor
        @registration.errors[:first_name] << 'too short' << 'too common'
        @registration.errors[:last_name] << 'too posh' << 'too weird'
        @registration.errors[:base] << 'Error 1' << 'Error 2'
      end

      it 'should have both base errors' do
        helper.one_full_message_per_invalid_attribute(@registration).should == ['First name too short', 'Last name too posh', 'Error 1', 'Error 2']
      end
    end
  end

  describe 'google analytics status colours' do
    it 'should show as green if complete' do
      session = {}
      helper.set_google_analytics_status_color(session, RegistrationsHelper::STATUS_COMPLETE)
      session[:ga_status_color].should == 'green'
    end
    
    it 'should show as green if complete for lower tier' do
      session = {}
      helper.set_google_analytics_status_color(session, RegistrationsHelper::STATUS_COMPLETE_LOWER)
      session[:ga_status_color].should == 'green'
    end

    it 'should show as amber if almost complete' do
      session = {}
      helper.set_google_analytics_status_color(session, RegistrationsHelper::STATUS_ALMOST_COMPLETE)
      session[:ga_status_color].should == 'amber'
    end

    it 'should show as amber if criminally suspect' do
      session = {}
      helper.set_google_analytics_status_color(session, RegistrationsHelper::STATUS_CRIMINALLY_SUSPECT)
      session[:ga_status_color].should == 'amber'
    end

    it 'should show as empty otherwise' do
      session = {:ga_status_color => 'green'}
      session.has_key?(:ga_status_color).should be_truthy
      helper.set_google_analytics_status_color(session, nil)
      session.has_key?(:ga_status_color).should be_falsey
    end

  end
end
