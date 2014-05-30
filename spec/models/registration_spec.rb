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

  context 'businessdetails step' do
    subject { Registration.new }

    before { subject.current_step = 'businessdetails' }

    it { should validate_presence_of(:companyName).with_message(/must be completed/) }
    it { should allow_value('a' * 70, 'Dun & Bradstreet', '37signals', "Barry's Bikes").for(:companyName) }
    it { should_not allow_value('a' * 71, '', '<script>alert("hi");</script>').for(:companyName) }
  end

  context 'contactdetails step' do
    describe 'presence' do
      subject { Registration.new }

      before { subject.current_step = 'contactdetails' }

      it { should validate_presence_of(:firstName).with_message(/must be completed/) }
      it { should validate_presence_of(:lastName).with_message(/must be completed/) }
      it { should validate_presence_of(:position).with_message(/must be completed/) }
      it { should validate_presence_of(:phoneNumber).with_message(/must be completed/) }
      it { should validate_presence_of(:contactEmail).with_message(/must be completed/) }
    end

    describe 'format' do
      subject { Registration.new(firstName: 'Barry', position: 'Pub landlord', lastName: 'Butler', phoneNumber: '999', contactEmail: 'barry@butler.com' ) }

      before { subject.current_step = 'contactdetails' }

      it { should allow_value('John', 'John-Paul', 'Sally Ann', "T'pau").for(:firstName) }
      it { should_not allow_value('Johnnie5', 'K.R.S One').for(:firstName) }
    end
  end
end