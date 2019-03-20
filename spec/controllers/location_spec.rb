require 'spec_helper'

describe LocationController, :type => :controller do

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

    context "when 'england' is selected" do

      let(:registration) { Registration.create }

      it "sets #location to 'england' on the registration" do
        post :create, :registration => { "location" => "england" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).location).to eq('england')
      end

      it "redirects to the 'business type' page" do
        post :create, :registration => { "location" => "england" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :business_type
      end

    end

    context "when 'wales' is selected" do

      let(:registration) { Registration.create }

      it "sets #location to 'wales' on the registration" do
        post :create, :registration => { "location" => "wales" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).location).to eq('wales')
      end

      it "redirects to the 'register in wales' page" do
        post :create, :registration => { "location" => "wales" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :register_in_wales
      end

    end

    context "when 'scotland' is selected" do

      let(:registration) { Registration.create }

      it "sets #location to 'scotland' on the registration" do
        post :create, :registration => { "location" => "scotland" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).location).to eq('scotland')
      end

      it "redirects to the 'register in scotland' page" do
        post :create, :registration => { "location" => "scotland" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :register_in_scotland
      end

    end

    context "when 'northern_ireland' is selected" do

      let(:registration) { Registration.create }

      it "sets #location to 'northern_ireland' on the registration" do
        post :create, :registration => { "location" => "northern_ireland" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).location).to eq('northern_ireland')
      end

      it "redirects to the 'register in northern ireland' page" do
        post :create, :registration => { "location" => "northern_ireland" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :register_in_northern_ireland
      end

    end

    context "when 'overseas' is selected" do

      let(:registration) { Registration.create }

      it "sets #location to 'overseas' on the registration" do
        post :create, :registration => { "location" => "overseas" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).location).to eq('overseas')
      end

      it "redirects to the 'business type' page" do
        post :create, :registration => { "location" => "overseas" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :business_type
      end

    end

    context "when no selection is made" do

      let(:registration) { Registration.create }

      it 'does not set #location' do
        post :create, :registration => { "location" => "" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).location).to eq('')
      end

      it "re-renders the 'location' page with a HTTP status code of 400" do
        post :create, :registration => { "location" => "" }, reg_uuid: registration.reg_uuid
        expect(response).to render_template("show")
        expect(response.code).to eq('400')
      end

    end

  end

end
