require 'spec_helper'

describe RegistrationsHelper do
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
      session[:ga_status_color].should == 'complete'
    end

    it 'should show as green if complete for lower tier' do
      session = {}
      helper.set_google_analytics_status_color(session, RegistrationsHelper::STATUS_COMPLETE_LOWER)
      session[:ga_status_color].should == 'complete'
    end

    it 'should show as amber if almost complete' do
      session = {}
      helper.set_google_analytics_status_color(session, RegistrationsHelper::STATUS_ALMOST_COMPLETE)
      session[:ga_status_color].should == 'pending'
    end

    it 'should show as amber if criminally suspect' do
      session = {}
      helper.set_google_analytics_status_color(session, RegistrationsHelper::STATUS_CRIMINALLY_SUSPECT)
      session[:ga_status_color].should == 'pending'
    end

    it 'should show as empty otherwise' do
      session = {:ga_status_color => 'green'}
      session.has_key?(:ga_status_color).should be_truthy
      helper.set_google_analytics_status_color(session, nil)
      session.has_key?(:ga_status_color).should be_falsey
    end

  end
end
