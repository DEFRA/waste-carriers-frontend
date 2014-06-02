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
      xit { should validate_presence_of(:contactEmail).with_message(/must be completed/) }

      it "should do different presence things for email based on assisted digital"
    end

    describe 'format' do
      subject { Registration.new(firstName: 'Barry', position: 'Pub landlord', lastName: 'Butler', phoneNumber: '999', contactEmail: 'barry@butler.com' ) }

      before { subject.current_step = 'contactdetails' }

      it { should allow_value('John', 'John-Paul', 'Sally Ann', "T'pau").for(:firstName) }
      it { should_not allow_value('Johnnie5', 'K.R.S One').for(:firstName) }
      it { should ensure_length_of(:firstName).is_at_most(35) }

      it { should allow_value('Butler', 'Foster-Jones', 'McTavish', 'Mc Hale', "O'Brien").for(:lastName) }
      it { should_not allow_value('1').for(:lastName) }
      it { should ensure_length_of(:lastName).is_at_most(35) }

      it { should allow_value('Foreman', 'Ruby Dev', 'Change-manager').for(:position) }
      it { should_not allow_value('Big Guy 1').for(:position) }

      it { should allow_value('0117 9109099', '(0)117 9109099', '+44 (0)117 9109099', '+44 (0)117 91-09099').for(:phoneNumber) }
      it { should_not allow_value('999', 'my landline', 'home').for(:phoneNumber) }
      it { should ensure_length_of(:phoneNumber).is_at_most(20) }

      it { should allow_value('user@foo.COM', 'A_US-ER@f.b.org', 'frst.lst@foo.jp', 'a+b@baz.cn').for(:contactEmail) }
      xit { should_not allow_value('barry@butler@foo.com' 'user@foo,com', 'user_at_foo.org', 'example.user@foo.', 'foo@bar_baz.com', 'foo@bar+baz.com').for(:contactEmail) }
    end
  end

  context 'signup step' do
    subject { Registration.new }

    before { subject.current_step = 'signup' }

    describe 'presence' do
      xit { should validate_presence_of(:accountEmail).with_message(/must be completed/) }
      xit { should validate_presence_of(:accountEmail_confirmation).with_message(/must be completed/) }
      xit { should validate_presence_of(:password).with_message(/must be completed/) }
      xit { should validate_presence_of(:password_confirmation).with_message(/must be completed/) }
    end

    context 'format' do
      subject { Registration.new(accountEmail: 'a@b.com', accountEmail_confirmation: 'a@b.com', password: 'please123', password_confirmation: 'please123') }

      before { subject.current_step = 'signup' }

      context 'with signup mode' do
        before { subject.signup_mode = 'sign_up' }

        xit { should allow_value('user@foo.COM', 'A_US-ER@f.b.org', 'frst.lst@foo.jp', 'a+b@baz.cn').for(:accountEmail) }
        xit { should_not allow_value('barry@butler@foo.com' 'user@foo,com', 'user_at_foo.org', 'example.user@foo.', 'foo@bar_baz.com', 'foo@bar+baz.com').for(:accountEmail) }

        xit { should allow_value('user@foo.COM', 'A_US-ER@f.b.org', 'frst.lst@foo.jp', 'a+b@baz.cn').for(:accountEmail_confirmation) }
        xit { should_not allow_value('barry@butler@foo.com' 'user@foo,com', 'user_at_foo.org', 'example.user@foo.', 'foo@bar_baz.com', 'foo@bar+baz.com').for(:accountEmail_confirmation) }

        xit { should allow_value('myPass145', 'myPass145$').for(:password) }
        xit { should_not allow_value('123', '123abc', 'aaaaa').for(:password) }

        xit { should allow_value('myPass145', 'myPass145$').for(:password_confirmation) }
        xit { should_not allow_value('123', '123abc', 'aaaaa').for(:password_confirmation) }
      end

      context 'without signup mode' do
        before { subject.sign_up_mode = '' }
      end
    end
  end
end