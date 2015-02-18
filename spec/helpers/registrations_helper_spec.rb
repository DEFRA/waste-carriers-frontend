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

end
