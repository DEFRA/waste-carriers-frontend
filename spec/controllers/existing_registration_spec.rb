require 'spec_helper'

describe ExistingRegistrationController, type: :controller do

  describe 'GET #show' do
    let(:registration) { Registration.create }

    it 'responds successfully with a HTTP 200 status code' do
      get :show, reg_uuid: registration.reg_uuid
      expect(response.code).to eq('200')
    end

    it 'renders the #show template' do
      get :show, reg_uuid: registration.reg_uuid
      expect(response).to render_template('show')
    end
  end

  describe 'POST #create' do
    context "when an existing 'IR' registration no. is entered" do
      let(:registration) { Registration.create }

      VALID_REG_NO = 'CB/AE888XX/A001'
      INVALID_REG_NO = " \t\n\r  Cb/aE888Xx/A001 \t "

      it "sets #originalRegistrationNumber to '#{VALID_REG_NO}' on the registration" do
        post :create, registration: { originalRegistrationNumber: VALID_REG_NO }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).originalRegistrationNumber).to eq(VALID_REG_NO)
      end

      it "sets #originalRegistrationNumber to '#{VALID_REG_NO}' from '#{INVALID_REG_NO}' on the registration" do
        post :create, registration: { originalRegistrationNumber: INVALID_REG_NO }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).originalRegistrationNumber).to eq(VALID_REG_NO)
      end

      it "redirects to the 'business type' page" do
        skip('a solution to populating IR data during tests')
        post :create, registration: { originalRegistrationNumber: VALID_REG_NO }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :business_type
      end
    end

    context "when an existing 'Upper tier' registration no. is entered" do
      let(:registration) { Registration.create }

      it "sets #originalRegistrationNumber to 'CBDU1' on the registration" do
        post :create, registration: { originalRegistrationNumber: 'CBDU1' }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).originalRegistrationNumber).to eq('CBDU1')
      end

      it "redirects to the 'User sign in' page" do
        skip('"a solution to populating registration data during tests')
        post :create, registration: { originalRegistrationNumber: 'CBDU1' }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :new_user_session
      end
    end

    context 'when an unrecognised entry is made' do
      let(:registration) { Registration.create }

      it 'does not set #originalRegistrationNumber' do
        post :create, registration: { originalRegistrationNumber: '1234XYZ' }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).originalRegistrationNumber).to eq('1234XYZ')
      end

      it "re-renders the 'existing registration' page with a HTTP status code of 400" do
        post :create, registration: { originalRegistrationNumber: '1234XYZ' }, reg_uuid: registration.reg_uuid
        expect(response).to render_template('show')
        expect(response.code).to eq('400')
      end
    end

    context '"when no entry is made' do
      let(:registration) { Registration.create }

      it 'does not set #originalRegistrationNumber' do
        post :create, registration: { originalRegistrationNumber: '' }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).originalRegistrationNumber).to eq('')
      end

      it "re-renders the 'existing registration' page with a HTTP status code of 400" do
        post :create, registration: { originalRegistrationNumber: '' }, reg_uuid: registration.reg_uuid
        expect(response).to render_template('show')
        expect(response.code).to eq('400')
      end
    end
  end

  describe "#can_renew_ir_registration?" do
    let(:registration) { Registration.create }
    let(:existing_registration_controller) { ExistingRegistrationController.new }

    before(:each) do
      registration.originalRegistrationNumber = "CB/AE888XX/A001"
    end

    context "when the IR registration is eligible for renewal" do
      before(:each) do
        registration.originalDateExpiry = date_to_utc_milliseconds(Date.tomorrow)
        existing_registration_controller.instance_variable_set(:@registration, registration)
      end

      it "can be renewed" do
        expect(existing_registration_controller.send(:can_renew_ir_registration?)).to eq(true)
      end
    end

    context "when the IR registration is expired" do
      before(:each) do
        registration.originalDateExpiry = date_to_utc_milliseconds(Date.today)
        existing_registration_controller.instance_variable_set(:@registration, registration)
      end

      it "cannot be renewed" do
        expect(existing_registration_controller.send(:can_renew_ir_registration?)).to eq(false)
      end
    end

    context "when the IR registration expires outside the renewal window" do
      before(:each) do
        registration.originalDateExpiry = date_to_utc_milliseconds(Date.today + 7.months)
        existing_registration_controller.instance_variable_set(:@registration, registration)
      end

      it "cannot be renewed" do
        expect(existing_registration_controller.send(:can_renew_ir_registration?)).to eq(false)
      end
    end

    context "when the IR registration has already been renewed" do
      it "cannot be renewed" do
        skip("a solution to populating registration data during tests")
        expect(existing_registration_controller.send(:can_renew_ir_registration?)).to eq(false)
      end
    end

  end

  describe "#expired?" do
    let(:registration) { Registration.create }
    let(:existing_registration_controller) { ExistingRegistrationController.new }

    before(:each) do
      existing_registration_controller.instance_variable_set(:@registration, registration)
    end

    context "when the expiry date is yesterday" do
      let(:expiry_date) { Date.yesterday }

      it "should be expired" do
        expect(existing_registration_controller.send(:expired?, expiry_date)).to eq(true)
      end
    end

    context "when the expiry date is today" do
      let(:expiry_date) { Date.today }

      it "should be expired" do
        expect(existing_registration_controller.send(:expired?, expiry_date)).to eq(true)
      end
    end

    context "when the expiry date is tomorrow" do
      let(:expiry_date) { Date.tomorrow }

      it "should not be expired" do
        expect(existing_registration_controller.send(:expired?, expiry_date)).to eq(false)
      end
    end
  end

  describe "#in_renewal_window?" do
    let(:registration) { Registration.create }
    let(:existing_registration_controller) { ExistingRegistrationController.new }

    before(:each) do
      existing_registration_controller.instance_variable_set(:@registration, registration)
    end

    context "when the renewal window is 3 months" do
      before do
        Rails.configuration.stub(:registration_renewal_window).and_return(3.months)
      end

      context "when the expiry date is 3 months and 2 days from today" do
        let(:expiry_date) { 3.months.from_now + 2.day }

        it "should not be in the window" do
          expect(existing_registration_controller.send(:in_renewal_window?, expiry_date)).to eq(false)
        end
      end

      context "when the expiry date is 3 months and 1 day from today" do
        let(:expiry_date) { 3.months.from_now + 1.day }

        it "should not be in the window" do
          expect(existing_registration_controller.send(:in_renewal_window?, expiry_date)).to eq(false)
        end
      end

      context "when the expiry date is 3 months from today" do
        let(:expiry_date) { 3.months.from_now }

        it "should be in the window" do
          expect(existing_registration_controller.send(:in_renewal_window?, expiry_date)).to eq(true)
        end
      end

      context "when the expiry date is less than 3 months from today" do
        let(:expiry_date) { 3.months.from_now - 1.day }

        it "should be in the window" do
          expect(existing_registration_controller.send(:in_renewal_window?, expiry_date)).to eq(true)
        end
      end
    end
  end

  describe "#status_eligible?" do
    let(:registration) { Registration.create }
    let(:existing_registration_controller) { ExistingRegistrationController.new }

    before(:each) do
      existing_registration_controller.instance_variable_set(:@registration, registration)
    end

    context "when the registration is ACTIVE" do
      it "should be eligible" do
        expect(existing_registration_controller.send(:status_eligible?, 'ACTIVE')).to eq(true)
      end
    end

    ['PENDING', 'REVOKED', 'EXPIRED', 'INACTIVE'].each do |status|
      context "when the registration is #{status}" do
        it "should not be eligible" do
          expect(existing_registration_controller.send(:status_eligible?, status)).to eq(false)
        end
      end
    end
  end
end
