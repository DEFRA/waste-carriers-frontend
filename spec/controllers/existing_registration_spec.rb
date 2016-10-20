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
end
