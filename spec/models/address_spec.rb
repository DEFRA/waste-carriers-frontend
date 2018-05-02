require 'spec_helper'

describe Address, type: :model do
  context 'manual-uk addressMode' do
    before { subject.addressMode = 'manual-uk' }

    describe 'presence' do
      it { is_expected.to validate_presence_of(:houseNumber).with_message(/You must enter/) }
      it { is_expected.to validate_presence_of(:addressLine1).with_message(/You must enter/) }
      it { is_expected.not_to validate_presence_of(:addressLine2).with_message(/You must enter/) }
      it { is_expected.to validate_presence_of(:townCity).with_message(/You must enter/) }
      it { is_expected.to validate_presence_of(:postcode).with_message(/You must enter/) }
    end

    describe 'format' do
      it { is_expected.to allow_value('1', '1a', 'Cloud-Base', "Lockeeper's Cottage").for(:houseNumber) }
      it { is_expected.not_to allow_value('£2').for(:houseNumber).with_message(/The building name or number can use letters, numbers, spaces and some special characters/) }
      it { is_expected.to allow_value('Bristol', 'Newcastle-upon-Type', 'Leamington Spa', "Gerrard's Cross").for(:townCity)}
      it { is_expected.not_to allow_value('Bristol!', 'District 9').for(:townCity) }
      it { is_expected.to allow_value('BS1 5AH', 'BS22 5AH').for(:postcode) }
      it { is_expected.not_to allow_value('1234', 'blah').for(:postcode) }
    end

    describe 'length' do
      it { is_expected.to validate_length_of(:houseNumber).is_at_most(35) }
      it { is_expected.to validate_length_of(:addressLine1).is_at_most(35) }
      it { is_expected.to validate_length_of(:addressLine2).is_at_most(35) }
    end
  end

  context 'manual-foreign addressMode' do
    before { subject.addressMode = 'manual-foreign' }

    describe 'presence' do
      it { is_expected.to validate_presence_of(:addressLine1).with_message(/You must enter/) }
      it { is_expected.not_to validate_presence_of(:addressLine2).with_message(/You must enter/) }
      it { is_expected.not_to validate_presence_of(:addressLine3) }
      it { is_expected.not_to validate_presence_of(:addressLine4) }
      it { is_expected.not_to validate_presence_of(:townCity) }
      it { is_expected.to validate_presence_of(:country).with_message(/You must enter/) }
    end

    describe 'length' do
      it { is_expected.to validate_length_of(:addressLine1).is_at_most(35) }
      it { is_expected.to validate_length_of(:addressLine2).is_at_most(35) }
      it { is_expected.to validate_length_of(:addressLine3).is_at_most(35) }
      it { is_expected.to validate_length_of(:addressLine4).is_at_most(35) }
      it { is_expected.to validate_length_of(:country).is_at_most(35) }
    end

    describe 'format' do
      it { is_expected.to allow_value('Paris', 'Amsterdam', 'Warsaw').for(:townCity) }
      it { is_expected.not_to allow_value('Paris!', 'District 9').for(:townCity) }
    end
  end
end
