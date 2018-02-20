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

  describe "#can_renew_registration?" do
    let(:existing_registration_controller) { ExistingRegistrationController.new }
    let(:registration) do
      registration = Registration.ctor
      registration.tier = "UPPER"
      registration.originalRegistrationNumber = "CBDU1"
      registration.expires_on = date_to_utc_milliseconds(Date.tomorrow)
      registration.metaData.first.update(status: 'ACTIVE')
      registration
    end

    context "when the registration is eligible for renewal" do
      it "can be renewed" do
        existing_registration_controller.instance_variable_set(:@registration, registration)

        expect(existing_registration_controller.send(:can_renew_registration?)).to eq(true)
      end
    end

    context "when the registration is expired" do
      it "cannot be renewed" do
        registration.expires_on = date_to_utc_milliseconds(Date.today)
        existing_registration_controller.instance_variable_set(:@registration, registration)

        expect(existing_registration_controller.send(:can_renew_registration?)).to eq(false)
      end
    end

    context "when the registration expires outside the renewal window" do
      it "cannot be renewed" do
        registration.expires_on = date_to_utc_milliseconds(Date.today + 7.months)
        existing_registration_controller.instance_variable_set(:@registration, registration)

        expect(existing_registration_controller.send(:can_renew_registration?)).to eq(false)
      end
    end

    context "when the registration is not ACTIVE" do
      it "cannot be renewed" do
        registration.metaData.first.update(status: 'INACTIVE')
        existing_registration_controller.instance_variable_set(:@registration, registration)
        expect(existing_registration_controller.send(:can_renew_registration?)).to eq(false)
      end
    end

    context "when the registration is lower tier" do
      it "cannot be renewed" do
        registration.tier = "LOWER"
        existing_registration_controller.instance_variable_set(:@registration, registration)
        expect(existing_registration_controller.send(:can_renew_registration?)).to eq(false)
      end
    end
  end

  describe "#can_renew_ir_registration?" do
    let(:existing_registration_controller) { ExistingRegistrationController.new }
    let(:registration) do
      registration = Registration.ctor
      registration.originalRegistrationNumber = "CB/AE888XX/A001"
      registration.originalDateExpiry = date_to_utc_milliseconds(Date.tomorrow)
      registration
    end

    context "when the IR registration is eligible for renewal" do
      it "can be renewed" do
        existing_registration_controller.instance_variable_set(:@registration, registration)

        expect(existing_registration_controller.send(:can_renew_ir_registration?)).to eq(true)
      end
    end

    context "when the IR registration is expired" do
      it "cannot be renewed" do
        registration.originalDateExpiry = date_to_utc_milliseconds(Date.today)
        existing_registration_controller.instance_variable_set(:@registration, registration)

        expect(existing_registration_controller.send(:can_renew_ir_registration?)).to eq(false)
      end
    end

    context "when the IR registration expires outside the renewal window" do
      it "cannot be renewed" do
        registration.originalDateExpiry = date_to_utc_milliseconds(Date.today + 7.months)
        existing_registration_controller.instance_variable_set(:@registration, registration)
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
