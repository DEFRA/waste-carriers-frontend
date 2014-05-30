require 'spec_helper'

describe Registration do
  context 'businesstype step' do
    subject { Registration.new }

    it { should validate_presence_of(:businessType).with_message(/must be completed/) }
    it { should allow_value('soleTrader', 'partnership', 'limitedCompany', 'publicBody', 'charity', 'authority', 'other').for(:businessType) }
    it { should_not allow_value('sole_trader', 'plc', 'collectionAuthority', 'disposalAuthority', 'regulationAuthority').for(:businessType) }
  end

  context 'otherbusinesses step' do
    subject { Registration.new }

    before { subject.current_step = 'otherbusinesses' }

    it { should validate_presence_of(:otherBusinesses).with_message(/must be completed/) }
    it { should allow_value('yes', 'no').for(:otherBusinesses) }
    it { should_not allow_value('y', 'n').for(:otherBusinesses) }
  end

  context 'serviceprovided step' do
    subject { Registration.new }

    before { subject.current_step = 'serviceprovided' }

    it { should validate_presence_of(:isMainService).with_message(/must be completed/) }
    it { should allow_value('yes', 'no').for(:isMainService) }
    it { should_not allow_value('y', 'n').for(:isMainService) }
  end

  context 'constructiondemolition step' do
    subject { Registration.new }

    before { subject.current_step = 'constructiondemolition' }

    it { should validate_presence_of(:constructionWaste).with_message(/must be completed/) }
    it { should allow_value('yes', 'no').for(:constructionWaste) }
    it { should_not allow_value('y', 'n').for(:constructionWaste) }
  end

  context 'onlydealwith step' do
    subject { Registration.new }

    before { subject.current_step = 'onlydealwith' }

    it { should validate_presence_of(:onlyAMF).with_message(/must be completed/) }
    it { should allow_value('yes', 'no').for(:onlyAMF) }
    it { should_not allow_value('y', 'n').for(:onlyAMF) }
  end
end