require 'spec_helper'

describe Registration do
  VALID_EMAIL_ADDRESSES = ['user@foo.COM', 'A_US-ER@f.b.org', 'frst.lst@foo.jp', 'a+b@baz.cn']
  INVALID_EMAIL_ADDRESSES = ['barry@butler@foo.com' 'user@foo,com', 'user_at_foo.org', 'example.user@foo.', 'foo@bar_baz.com', 'foo@bar+baz.com']

  VALID_TELEPHONE_NUMBERS = ['0117 9109099', '(0)117 9109099', '+44 (0)117 9109099', '+44 (0)117 91-09099']
  INVALID_TELEPHONE_NUMBERS = ['999', 'my landline', 'home']

  VALID_JOB_TITLES = ['Foreman', 'Ruby Dev', 'Change-manager']
  INVALID_JOB_TITLES = ['Big Guy 1', 'Employee #1']

  GOOD_PASSWORDS = ['myPass145', 'myPass145$']
  WEAK_PASSWORDS = ['123', '123abc', 'aaaaa']

  context 'businesstype step' do
    before { subject.current_step = 'businesstype' }

    it { should validate_presence_of(:businessType).with_message(/must be completed/) }
    it { should allow_value('soleTrader', 'partnership', 'limitedCompany', 'publicBody', 'charity', 'authority', 'other').for(:businessType) }
    it { should_not allow_value('sole_trader', 'plc', 'collectionAuthority', 'disposalAuthority', 'regulationAuthority').for(:businessType) }
  end

  context 'otherbusinesses step' do
    before { subject.current_step = 'otherbusinesses' }

    it { should validate_presence_of(:otherBusinesses).with_message(/must be completed/) }
    it { should allow_value('yes', 'no').for(:otherBusinesses) }
    it { should_not allow_value('y', 'n').for(:otherBusinesses) }
  end

  context 'serviceprovided step' do
    before { subject.current_step = 'serviceprovided' }

    it { should validate_presence_of(:isMainService).with_message(/must be completed/) }
    it { should allow_value('yes', 'no').for(:isMainService) }
    it { should_not allow_value('y', 'n').for(:isMainService) }
  end

  context 'constructiondemolition step' do
    before { subject.current_step = 'constructiondemolition' }

    it { should validate_presence_of(:constructionWaste).with_message(/must be completed/) }
    it { should allow_value('yes', 'no').for(:constructionWaste) }
    it { should_not allow_value('y', 'n').for(:constructionWaste) }
  end

  context 'onlydealwith step' do
    before { subject.current_step = 'onlydealwith' }

    it { should validate_presence_of(:onlyAMF).with_message(/must be completed/) }
    it { should allow_value('yes', 'no').for(:onlyAMF) }
    it { should_not allow_value('y', 'n').for(:onlyAMF) }
  end

  context 'contactdetails step' do
    describe 'presence' do
      before { subject.current_step = 'contactdetails' }

      it { should validate_presence_of(:firstName).with_message(/must be completed/) }
      it { should validate_presence_of(:lastName).with_message(/must be completed/) }
      it { should validate_presence_of(:position).with_message(/must be completed/) }
      it { should validate_presence_of(:phoneNumber).with_message(/must be completed/) }
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

      it { should allow_value(*VALID_JOB_TITLES).for(:position) }
      it { should_not allow_value(*INVALID_JOB_TITLES).for(:position) }

      it { should allow_value(*VALID_TELEPHONE_NUMBERS).for(:phoneNumber) }
      it { should_not allow_value(*INVALID_TELEPHONE_NUMBERS).for(:phoneNumber) }
      it { should ensure_length_of(:phoneNumber).is_at_most(20) }

      context 'digital route' do
        before { subject.routeName = 'DIGITAL' }

        it { should validate_presence_of(:contactEmail).with_message(/must be completed/) }

        it { should allow_value(*VALID_EMAIL_ADDRESSES).for(:contactEmail) }
        it { should_not allow_value(*INVALID_EMAIL_ADDRESSES).for(:contactEmail) }
      end

      context 'assisted digital route' do
        before { subject.routeName = 'ASSISTED_DIGITAL' }

        it { should_not validate_presence_of(:contactEmail) }
      end
    end
  end

  context 'businessdetails step' do
    before { subject.current_step = 'businessdetails' }

    it { should validate_presence_of(:companyName).with_message(/must be completed/) }
    it { should allow_value('Dun & Bradstreet', '37signals', "Barry's Bikes").for(:companyName) }
    it { should_not allow_value('<script>alert("hi");</script>').for(:companyName) }
    it { should ensure_length_of(:companyName).is_at_most(70) }

    it { should allow_value('manual-uk', 'manual-foreign').for(:addressMode) }
    it { should_not allow_value('uk', 'foreign').for(:addressMode) }

    context 'manual-uk addressMode' do
      before { subject.addressMode = 'manual-uk' }

      describe 'presence' do
        it { should validate_presence_of(:houseNumber).with_message(/must be completed/) }
        it { should validate_presence_of(:streetLine1).with_message(/must be completed/) }
        it { should_not validate_presence_of(:streetLine2).with_message(/must be completed/) }
        it { should validate_presence_of(:townCity).with_message(/must be completed/) }
        it { should validate_presence_of(:postcode).with_message(/must be completed/) }
      end

      describe 'format' do
        it { should allow_value('1', '1a', 'Cloud-Base', "Lockeeper's Cottage").for(:houseNumber) }
        it { should_not allow_value('£2').for(:houseNumber).with_message(/can only contain letters, spaces, numbers and hyphens and be no longer than 35 characters/) }
        it { should allow_value('Bristol', 'Newcastle-upon-Type', 'Leamington Spa', "Gerrard's Cross").for(:townCity)}
        it { should_not allow_value('Bristol!', 'District 9').for(:townCity) }
        it { should allow_value('BS1 5AH', 'BS22 5AH').for(:postcode) }
        it { should_not allow_value('1234', 'blah').for(:postcode) }
      end

      describe 'length' do
        it { should ensure_length_of(:houseNumber).is_at_most(35) }
        it { should ensure_length_of(:streetLine1).is_at_most(35) }
        it { should ensure_length_of(:streetLine2).is_at_most(35) }
      end
    end

    context 'manual-foreign addressMode' do
      before { subject.addressMode = 'manual-foreign' }

      describe 'presence' do
        it { should validate_presence_of(:streetLine1).with_message(/must be completed/) }
        it { should_not validate_presence_of(:streetLine2).with_message(/must be completed/) }
        it { should_not validate_presence_of(:streetLine3) }
        it { should_not validate_presence_of(:streetLine4) }
        it { should validate_presence_of(:country).with_message(/must be completed/) }
      end

      describe 'length' do
        it { should ensure_length_of(:streetLine1).is_at_most(35) }
        it { should ensure_length_of(:streetLine2).is_at_most(35) }
        it { should ensure_length_of(:streetLine3).is_at_most(35) }
        it { should ensure_length_of(:streetLine4).is_at_most(35) }
        it { should ensure_length_of(:country).is_at_most(35) }
      end
    end

    context 'without addressMode' do
      before { subject.addressMode = nil }

      describe 'presence' do
        it { should validate_presence_of(:postcodeSearch) }
      end

      describe 'format' do
        it { should allow_value('BS1 5AH', 'BS22 5AH').for(:postcodeSearch) }
        it { should_not allow_value('1234', 'blah').for(:postcodeSearch) }
      end

      context 'with postcodeSearch but no address found' do
        before do
          subject.postcodeSearch = 'BS11 JAH'
          subject.uprn = nil
        end

        it { should validate_presence_of(:selectedMoniker) }
      end
    end
  end

  context 'signup step' do
    before { subject.current_step = 'signup' }

    describe 'presence' do

      context 'without signup mode' do
        it { should_not validate_presence_of(:accountEmail) }
      end

      context 'sign_in signup mode' do
        before { subject.sign_up_mode = 'sign_in' }

        it { should validate_presence_of(:accountEmail).with_message(/must be completed/) }
      end

      context 'sign_up signup mode' do
        before { subject.sign_up_mode = 'sign_up' }

        it { should validate_presence_of(:accountEmail).with_message(/must be completed/) }

        context 'unpersisted' do
          before { allow(subject).to receive(:persisted?).and_return(false) }

          it { should validate_presence_of(:password).with_message(/must be completed/) }
          it { should validate_confirmation_of(:password) }

          describe 'unique user registration using accountEmail' do
            context 'User exists with supplied accountEmail' do
              let(:user) { FactoryGirl.create :user }

              it { should_not allow_value(user.email).for(:accountEmail) }
            end
          end
        end
      end
    end

    context 'format' do
      subject { Registration.new(accountEmail: 'a@b.com', accountEmail_confirmation: 'a@b.com', password: 'please123', password_confirmation: 'please123') }

      before { subject.current_step = 'signup' }

      context 'sign_in signup mode' do
        before { subject.sign_up_mode = 'sign_in' }

        it { should allow_value(*VALID_EMAIL_ADDRESSES).for(:accountEmail) }
        it { should_not allow_value(*INVALID_EMAIL_ADDRESSES).for(:accountEmail) }
      end

      context 'sign_up signup mode' do
        before { subject.sign_up_mode = 'sign_up' }

        it { should allow_value(*VALID_EMAIL_ADDRESSES).for(:accountEmail) }
        it { should_not allow_value(*INVALID_EMAIL_ADDRESSES).for(:accountEmail) }

        context 'unpersisted' do
          before { allow(subject).to receive(:persisted?).and_return(false) }

          it { should allow_value(*GOOD_PASSWORDS).for(:password) }
          it { should_not allow_value(*WEAK_PASSWORDS).for(:password) }

          it { should ensure_length_of(:password).is_at_least(8).is_at_most(128) }

          it { should validate_confirmation_of(:accountEmail) }
        end
      end

      context 'unpersisted' do
        before { allow(subject).to receive(:persisted?).and_return(false) }

        it { should allow_value('sign_up', 'sign_in').for(:sign_up_mode) }
        xit { should_not allow_value('signup', 'signin').for(:sign_up_mode) }

        context 'with accountEmail' do
          xit { should validate_presence_of(:sign_up_mode) }
        end
      end
    end
  end

  context 'confirmation step' do
    before { subject.current_step = 'confirmation' }

    it { should validate_acceptance_of(:declaration) }
  end

  context 'registrationtype step' do
    before { subject.current_step = 'registrationtype' }

    it { should validate_presence_of(:registrationType) }

    it { should allow_value('carrier_dealer', 'broker_dealer', 'carrier_broker_dealer').for(:registrationType) }
    it { should_not allow_value('CARRIER_DEALER', 'BROKER_DEALER', 'CARRIER_BROKER_DEALER').for(:registrationType) }
  end

  context 'upper_business_details step' do
    before { subject.current_step = 'upper_business_details' }

    it { should validate_presence_of(:companyName) }

    context 'not a limited company' do
      before { subject.businessType = 'soleTrader' }

      it { should_not validate_presence_of(:company_no) }
    end

    context 'limited company' do
      before do
        subject.businessType = 'limitedCompany'
        subject.companyName = 'Biffa'
      end

      it { should validate_presence_of(:company_no) }

      it 'should not allow company which is not active', :vcr do
        subject.should_not allow_value('05868270').for(:company_no)
      end

      it 'should allow active company', :vcr do
        subject.should allow_value('02050399').for(:company_no)
      end

      context 'check format only' do
        before do
          allow_any_instance_of(CompaniesHouseCaller).to receive(:status).and_return(:active)
        end

        it { should allow_value('06731292', '6731292', '07589628', '7589628', '00000001', '1', 'ni123456', 'NI123456', 'RO123456', 'SC123456', 'OC123456', 'SO123456', 'NC123456', 'AC097609').for(:company_no) }
        it { should_not allow_value('NII12345', 'NI1234567', '123456789', '0', '00000000', '-12345678', '-1234567').for(:company_no) }
      end
    end
  end

  context 'upper_contact_details step' do
    before { subject.current_step = 'upper_contact_details' }

    it { should validate_presence_of(:firstName) }
    it { should validate_presence_of(:lastName) }
    it { should validate_presence_of(:position) }
    it { should validate_presence_of(:phoneNumber) }

    it { should allow_value(*VALID_TELEPHONE_NUMBERS).for(:phoneNumber) }
    it { should_not allow_value(*INVALID_TELEPHONE_NUMBERS).for(:phoneNumber) }
    it { should ensure_length_of(:phoneNumber).is_at_most(20) }

    context 'digital route' do
      before { subject.routeName = 'DIGITAL' }

      it { should validate_presence_of(:contactEmail) }

      it { should allow_value(*VALID_EMAIL_ADDRESSES).for(:contactEmail) }
      it { should_not allow_value(*INVALID_EMAIL_ADDRESSES).for(:contactEmail) }
    end

    context 'assisted digital route' do
      before { subject.routeName = 'ASSISTED_DIGITAL' }

      it { should_not validate_presence_of(:contactEmail) }
    end
  end

  context 'payment step' do
    before { subject.current_step = 'payment' }

    it { should validate_numericality_of(:copy_cards).is_greater_than_or_equal_to(0).only_integer }
  end

  context 'upper_summary step' do
    before { subject.current_step = 'upper_summary' }

    it { should validate_acceptance_of(:declaration) }
  end
end