require "spec_helper"
require Rails.root.join "spec/models/concerns/can_be_renewed_spec.rb"

describe Registration do

  it_behaves_like "can_be_renewed"

  it { is_expected.to respond_to :paid_in_full? }

  describe '#upper?' do
    specify { expect(Registration.ctor(tier: 'UPPER')).to be_upper }
    specify { expect(Registration.ctor(tier: 'upper')).not_to be_upper }
    specify { expect(Registration.ctor(tier: '')).not_to be_upper }
    specify { expect(Registration.ctor(tier: nil)).not_to be_upper }
    specify { expect(Registration.ctor(tier: 'LOWER')).not_to be_upper }
  end

  describe '#lower?' do
    specify { expect(Registration.ctor(tier: 'LOWER')).to be_lower }
    specify { expect(Registration.ctor(tier: 'lower')).not_to be_lower }
    specify { expect(Registration.ctor(tier: '')).to be_lower }
    specify { expect(Registration.ctor(tier: nil)).to be_lower }
    specify { expect(Registration.ctor(tier: 'UPPER')).not_to be_lower }
  end

  context 'businesstype step' do
    before { subject.current_step = 'businesstype' }

    it { is_expected.to validate_presence_of(:businessType).with_message(/You must answer this question/) }
    it { is_expected.to allow_value('soleTrader', 'partnership', 'limitedCompany', 'publicBody', 'charity', 'authority', 'other').for(:businessType) }
    it { is_expected.not_to allow_value('sole_trader', 'plc', 'collectionAuthority', 'disposalAuthority', 'regulationAuthority').for(:businessType) }
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

    it { is_expected.to allow_value('LOWER', 'UPPER').for(:tier) }

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
      it { is_expected.not_to validate_presence_of(:accountEmail) }
    end

    context 'sign_in signup mode' do
      before { subject.sign_up_mode = 'sign_in' }

      it { is_expected.to validate_presence_of(:accountEmail).with_message(/You must enter/) }
    end

    context 'sign_up signup mode' do
      before { subject.sign_up_mode = 'sign_up' }

      it_behaves_like 'email validation', :accountEmail
      it { is_expected.to validate_confirmation_of(:accountEmail).with_message(/You must confirm/) }

      context 'unpersisted' do
        before { allow(subject).to receive(:persisted?).and_return(false) }

        it_behaves_like 'password with strength restrictions'

        describe 'unique user registration using accountEmail' do
          context 'User exists with supplied accountEmail' do
            let(:user) { FactoryGirl.create :user }

            it { is_expected.not_to allow_value(user.email).for(:accountEmail) }
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

    it { is_expected.to validate_presence_of(:registrationType).with_message(/You must answer this question/) }

    it { is_expected.to allow_value('carrier_dealer', 'broker_dealer', 'carrier_broker_dealer').for(:registrationType) }
    it { is_expected.not_to allow_value('CARRIER_DEALER', 'BROKER_DEALER', 'CARRIER_BROKER_DEALER').for(:registrationType) }
  end

  context 'upper_business_details step' do
    subject { Registration.ctor }
    before { subject.current_step = 'businessdetails' }

    it_behaves_like 'a company name step'

    context 'not a limited company' do
      before { subject.businessType = 'soleTrader' }

      it { is_expected.not_to validate_presence_of(:company_no) }
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

      it { is_expected.not_to validate_presence_of(:company_no) }
      it { is_expected.to allow_value('12345', '11.22.33.AA.BB-C(EF)[GH]{IJ}', 'my SIREN number for 2016 is 6-5-4-3-2.1').for(:company_no) }
      it { is_expected.not_to allow_value('z' * (Registration::MAX_FOREIGN_COMPANY_NUMBER_LENGTH + 1)).for(:company_no) }
    end
  end

  context 'upper_contact_details step' do
    before { subject.current_step = 'contactdetails' }

    it_behaves_like 'a contact details step'
  end

  context 'payment step' do
    before { subject.current_step = 'payment' }

    it { is_expected.to validate_numericality_of(:copy_cards).is_greater_than_or_equal_to(0).only_integer }
  end

  context 'upper_summary step' do
    before { subject.current_step = 'upper_summary' }

    it_behaves_like 'an acceptance step'
  end

  describe "account_email_has_no_matching_user?" do
    context "when there is a matching account" do
      before do
        user = User.create(email: "thisexists@example.com", password: "Secret123")
        subject.accountEmail = user.email
      end

      it "returns false" do
        expect(subject.account_email_has_no_matching_user?).to eq(false)
      end
    end

    context "when there is no matching account" do
      before do
        subject.accountEmail = "thisdoesnotexist@example.com"
      end

      it "returns false" do
        expect(subject.account_email_has_no_matching_user?).to eq(true)
      end
    end
  end
end
