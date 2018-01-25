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

  describe '#isCurrentRegistrationType' do
    context 'when passed a digital style upper tier registration number' do
      it 'returns true' do
        expect(helper.isCurrentRegistrationType('CBDU215437')).to be_truthy
      end
    end

    context 'when passed a digital style lower tier registration number' do
      it 'returns true' do
        expect(helper.isCurrentRegistrationType('CBDL215437')).to be_truthy
      end
    end

    context 'when passed a digital style registration number with leading and trailing whitespace' do
      it 'returns true' do
        expect(helper.isCurrentRegistrationType('  CBDU215437   ')).to be_truthy
      end
    end

    context 'when passed a digital style registration number with lowercase characters' do
      it 'returns true' do
        expect(helper.isCurrentRegistrationType('cbdu215437')).to be_truthy
      end
    end

    context 'when passed an IR style registration number' do
      it 'returns false' do
        expect(helper.isCurrentRegistrationType('CB/AF7003CS/A001')).to be_falsey
      end
    end

    context 'when passed nonsense' do
      it 'returns false' do
        expect(helper.isCurrentRegistrationType('green eggs and ham')).to be_falsey
      end
    end

    context 'when passed nothing' do
      it 'errors' do
        expect { helper.isCurrentRegistrationType(nil) }.to raise_error
      end
    end
  end

end
