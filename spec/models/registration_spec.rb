require 'spec_helper'

describe Registration do

  context 'businesstype step' do
    before { subject.current_step = 'businesstype' }

    it { should validate_presence_of(:businessType).with_message(/must be completed/) }
    it { should allow_value('soleTrader', 'partnership', 'limitedCompany', 'publicBody', 'charity', 'authority', 'other').for(:businessType) }
    it { should_not allow_value('sole_trader', 'plc', 'collectionAuthority', 'disposalAuthority', 'regulationAuthority').for(:businessType) }
  end

  context 'otherbusinesses step' do
    before { subject.current_step = 'otherbusinesses' }

    it_behaves_like 'a yes or a no', :otherBusinesses
  end

  context 'serviceprovided step' do
    before { subject.current_step = 'serviceprovided' }

    it_behaves_like 'a yes or a no', :isMainService
  end

  context 'constructiondemolition step' do
    before { subject.current_step = 'constructiondemolition' }

    it_behaves_like 'a yes or a no', :constructionWaste
  end

  context 'onlydealwith step' do
    before { subject.current_step = 'onlydealwith' }

    it_behaves_like 'a yes or a no', :onlyAMF
  end

  context 'contactdetails step' do
    before { subject.current_step = 'contactdetails' }

    it_behaves_like 'a contact details step'
  end

  context 'businessdetails step' do
    before { subject.current_step = 'businessdetails' }

    it_behaves_like 'a company name step'
    it_behaves_like 'a physical address step'
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

          it { should allow_value('myPass145', 'myPass145$').for(:password) }
          it { should_not allow_value('123', '123abc', 'aaaaa').for(:password) }

          it { should ensure_length_of(:password).is_at_least(8).is_at_most(128) }

          it { should validate_confirmation_of(:accountEmail) }
        end
      end
    end
  end

  context 'confirmation step' do
    before { subject.current_step = 'confirmation' }

    it_behaves_like 'an acceptance step'
  end

  context 'registrationtype step' do
    before { subject.current_step = 'registrationtype' }

    it { should validate_presence_of(:registrationType) }

    it { should allow_value('carrier_dealer', 'broker_dealer', 'carrier_broker_dealer').for(:registrationType) }
    it { should_not allow_value('CARRIER_DEALER', 'BROKER_DEALER', 'CARRIER_BROKER_DEALER').for(:registrationType) }
  end

  context 'upper_business_details step' do
    before { subject.current_step = 'upper_business_details' }

    it_behaves_like 'a company name step'
    it_behaves_like 'a physical address step'

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

    it_behaves_like 'a contact details step'
  end

  context 'payment step' do
    before { subject.current_step = 'payment' }

    it { should validate_numericality_of(:copy_cards).is_greater_than_or_equal_to(0).only_integer }
  end

  context 'upper_summary step' do
    before { subject.current_step = 'upper_summary' }

    it_behaves_like 'an acceptance step'
  end
end