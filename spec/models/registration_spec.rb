require 'spec_helper'

describe Registration do
  context 'businesstype step' do
    subject { Registration.new(current_step: 'businesstype') }

    it { should validate_presence_of(:businessType).with_message(/must be completed/) }
    it { should allow_value('soleTrader', 'partnership', 'limitedCompany', 'publicBody', 'charity', 'collectionAuthority', 'disposalAuthority', 'regulationAuthority', 'other').for(:businessType) }
    it { should_not allow_value('sole_trader', 'plc').for(:businessType) }
  end

  context 'otherbusinesses step' do
    subject { Registration.new(current_step: 'otherbusinesses') }

    it { should validate_presence_of(:otherBusinesses).with_message(/must be completed/) }
    it { should allow_value('yes', 'no').for(:otherBusinesses) }
    it { should_not allow_value('y', 'n').for(:otherBusinesses) }
  end
end