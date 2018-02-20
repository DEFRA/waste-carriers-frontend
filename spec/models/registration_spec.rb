require 'spec_helper'

describe Registration do

  it { should respond_to :paid_in_full? }

  describe '#upper?' do
    specify { Registration.ctor(tier: 'UPPER').should be_upper }
    specify { Registration.ctor(tier: 'upper').should_not be_upper }
    specify { Registration.ctor(tier: '').should_not be_upper }
    specify { Registration.ctor(tier: nil).should_not be_upper }
    specify { Registration.ctor(tier: 'LOWER').should_not be_upper }
  end

  describe '#lower?' do
    specify { Registration.ctor(tier: 'LOWER').should be_lower }
    specify { Registration.ctor(tier: 'lower').should_not be_lower }
    specify { Registration.ctor(tier: '').should be_lower }
    specify { Registration.ctor(tier: nil).should be_lower }
    specify { Registration.ctor(tier: 'UPPER').should_not be_lower }
  end

  describe "#can_renew?" do
    subject do
      registration = Registration.ctor
      registration.originalRegistrationNumber = "CBDU1"
      registration.tier = "UPPER"
      registration.expires_on = date_to_utc_milliseconds(Date.tomorrow)
      registration.metaData.first.update(status: 'ACTIVE')
      registration
    end

    context "when the registration is eligible for renewal" do
      it "can be renewed" do
        expect(subject.can_renew?).to eq(true)
      end
    end

    context "when the registration is lower tier" do
      it "cannot be renewed" do
        subject.tier = "LOWER"
        expect(subject.can_renew?).to eq(false)
      end
    end

    context "when the registration is expired" do
      it "cannot be renewed" do
        subject.expires_on = date_to_utc_milliseconds(Date.today)
        expect(subject.can_renew?).to eq(false)
      end
    end

    context "when the registration is not ACTIVE" do
      it "cannot be renewed" do
        subject.metaData.first.update(status: 'REVOKED')
        expect(subject.can_renew?).to eq(false)
      end
    end

    context "when the registration expires outside the renewal window" do
      before do
        Rails.configuration.stub(:registration_renewal_window).and_return(3.months)
      end

      it "cannot be renewed" do
        expiry_date = (3.months.from_now + 2.day).to_date
        subject.expires_on = date_to_utc_milliseconds(expiry_date)
        expect(subject.can_renew?).to eq(false)
      end
    end
  end

  describe "#expired?" do
    subject do
      registration = Registration.ctor
      registration.tier = "UPPER"
      registration.expires_on = date_to_utc_milliseconds(Date.tomorrow)
      registration.metaData.first.update(status: 'ACTIVE')
      registration
    end

    context "when the registration is ACTIVE and not expired" do
      it "returns false" do
        expect(subject.expired?).to eq(false)
      end
    end

    context "when the registration's status is EXPIRED" do
      it "returns true" do
        subject.metaData.first.update(status: 'EXPIRED')
        expect(subject.expired?).to eq(true)
      end
    end

    context "when the registration expired yesterday" do
      it "returns true" do
        subject.expires_on = date_to_utc_milliseconds(Date.yesterday)
        expect(subject.expired?).to eq(true)
      end
    end

    context "when the registration is lower tier" do
      it "returns true" do
        subject.tier = "LOWER"
        expect(subject.expired?).to eq(false)
      end
    end
  end

  context 'businesstype step' do
    before { subject.current_step = 'businesstype' }

    it { should validate_presence_of(:businessType).with_message(/You must answer this question/) }
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

  context 'convictions step' do
    it "is implemented but waiting" do
      skip "waiting for validation messages completion for section 3 (convictions)"

      before { subject.current_step = 'convictions' }

      it_behaves_like 'a yes or a no', :declaredConvictions
    end
  end

  context 'contactdetails step' do
    before { subject.current_step = 'contactdetails' }

    it_behaves_like 'a contact details step'
  end

  context 'businessdetails step' do
    subject { Registration.ctor }
    before { subject.current_step = 'businessdetails' }

    it_behaves_like 'a company name step'
  end

  context 'signup step' do
    before do
      subject.current_step = 'signup'
      subject.tier = 'UPPER'
    end

    it { should allow_value('LOWER', 'UPPER').for(:tier) }

    context 'nil tier' do
      before { subject.tier = nil }

      it 'errors' do
        expect { subject.valid? }.to raise_error ActiveModel::StrictValidationFailed
      end
    end

    context 'empty tier' do
      before { subject.tier = '' }

      it 'errors' do
        expect { subject.valid? }.to raise_error ActiveModel::StrictValidationFailed
      end
    end

    context 'unrecognised tier' do
      before { subject.tier = 'lower' }

      it 'errors' do
        expect { subject.valid? }.to raise_error ActiveModel::StrictValidationFailed
      end
    end

    context 'without signup mode' do
      it { should_not validate_presence_of(:accountEmail) }
    end

    context 'sign_in signup mode' do
      before { subject.sign_up_mode = 'sign_in' }

      it { should validate_presence_of(:accountEmail).with_message(/You must enter/) }
    end

    context 'sign_up signup mode' do
      before { subject.sign_up_mode = 'sign_up' }

      it_behaves_like 'email validation', :accountEmail
      it { should validate_confirmation_of(:accountEmail).with_message(/You must confirm/) }

      context 'unpersisted' do
        before { allow(subject).to receive(:persisted?).and_return(false) }

        it_behaves_like 'password with strength restrictions'

        describe 'unique user registration using accountEmail' do
          context 'User exists with supplied accountEmail' do
            let(:user) { FactoryGirl.create :user }

            it { should_not allow_value(user.email).for(:accountEmail) }
          end
        end
      end
    end
  end

  context 'confirmation step' do
    before { subject.current_step = 'declaration' }

    it_behaves_like 'an acceptance step'
  end

  context 'registrationtype step' do
    before { subject.current_step = 'registrationtype' }

    it { should validate_presence_of(:registrationType).with_message(/You must answer this question/) }

    it { should allow_value('carrier_dealer', 'broker_dealer', 'carrier_broker_dealer').for(:registrationType) }
    it { should_not allow_value('CARRIER_DEALER', 'BROKER_DEALER', 'CARRIER_BROKER_DEALER').for(:registrationType) }
  end

  context 'upper_business_details step' do
    subject { Registration.ctor }
    before { subject.current_step = 'businessdetails' }

    it_behaves_like 'a company name step'

    context 'not a limited company' do
      before { subject.businessType = 'soleTrader' }

      it { should_not validate_presence_of(:company_no) }
    end

    context 'UK limited company (postcode-lookup address)' do
      before do
        subject.businessType = 'limitedCompany'
        subject.tier = 'UPPER'
        subject.registered_address.add(addressMode: 'address-results')
      end

      it_behaves_like 'a uk company number step'
    end

    context 'UK limited company (manual UK address)' do
      before do
        subject.businessType = 'limitedCompany'
        subject.tier = 'UPPER'
        subject.registered_address.add(addressMode: 'manual-uk')
      end

      it_behaves_like 'a uk company number step'
    end

    context 'foreign limited company' do
      before do
        subject.businessType = 'limitedCompany'
        subject.tier = 'UPPER'
        subject.registered_address.add(addressMode: 'manual-foreign')
      end

      it 'is a foreign limited company' do
        expect(subject.uk_limited_company?).to eq(false)
        expect(subject.foreign_limited_company?).to eq(true)
      end

      it { should_not validate_presence_of(:company_no) }
      it { should allow_value('12345', '11.22.33.AA.BB-C(EF)[GH]{IJ}', 'my SIREN number for 2016 is 6-5-4-3-2.1').for(:company_no) }
      it { should_not allow_value('z' * (Registration::MAX_FOREIGN_COMPANY_NUMBER_LENGTH + 1)).for(:company_no) }
    end
  end

  context 'upper_contact_details step' do
    before { subject.current_step = 'contactdetails' }

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
