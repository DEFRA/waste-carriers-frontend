require 'spec_helper'

describe Registration do
  context 'businesstype step' do
    subject { Registration.new(current_step: 'businesstype') }

    it { should validate_presence_of(:businessType).with_message(/must be completed/) }
    it { should allow_value('soleTrader', 'partnership', 'limitedCompany', 'publicBody', 'charity', 'authority', 'other').for(:businessType) }
    it { should_not allow_value('sole_trader', 'plc', 'collectionAuthority', 'disposalAuthority', 'regulationAuthority').for(:businessType) }
  end

  context 'otherbusinesses step' do
    before do
      @registration = Registration.new(current_step: 'otherbusinesses')
    end

    subject { @registration }

    it { should_not be_valid }

    describe 'with otherbusinesses yes' do
      before do
        @registration.otherBusinesses = 'yes'
      end

      it { should be_valid }
    end

    describe 'with otherbusinesses y' do
      before do
        @registration.otherBusinesses = 'y'
      end

      it { should_not be_valid }
    end
  end
end