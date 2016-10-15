require 'spec_helper'

describe OnlyDealWithController, :type => :controller do

  describe 'GET #show' do

    let(:registration) { Registration.create }

    it 'responds successfully with a HTTP 200 status code' do
      get :show, reg_uuid: registration.reg_uuid
      expect(response.code).to eq('200')
    end

    it 'renders the #show template' do
      get :show, reg_uuid: registration.reg_uuid
      expect(response).to render_template("show")
    end

  end

  describe 'POST #create' do

    context "when 'yes' is selected" do

      let(:registration) { Registration.create }

      it "sets #onlyAMF to 'yes' on the registration" do
        post :create, :registration => { "onlyAMF" => "yes" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).onlyAMF).to eq('yes')
      end

      it "redirects to the 'Business details' page" do
        post :create, :registration => { "onlyAMF" => "yes" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :business_details
      end

    end

    context "when 'no' is selected" do

      let(:registration) { Registration.create }

      it "sets #onlyAMF to 'no' on the registration" do
        post :create, :registration => { "onlyAMF" => "no" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).onlyAMF).to eq('no')
      end

      it "redirects to the 'Registration type' page" do
        post :create, :registration => { "onlyAMF" => "no" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :registration_type
      end

    end

    context "when no selection is made" do

      let(:registration) { Registration.create }

      it 'does not set #onlyAMF' do
        post :create, :registration => { "onlyAMF" => "" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).onlyAMF).to eq('')
      end

      it "re-renders the 'only deal with' page with a HTTP status code of 400" do
        post :create, :registration => { "onlyAMF" => "" }, reg_uuid: registration.reg_uuid
        expect(response).to render_template("show")
        expect(response.code).to eq('400')
      end

    end

  end

end
