require 'spec_helper'

describe BusinessTypeController, :type => :controller do

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

    context "when 'sole trader' is selected" do

      let(:registration) { Registration.create }

      it "sets #businessType to 'soleTrader' on the registration" do
        post :create, :registration => { "businessType" => "soleTrader" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).businessType).to eq('soleTrader')
      end

      it "redirects to the 'other businesses' page" do
        post :create, :registration => { "businessType" => "soleTrader" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :other_businesses
      end

    end

    context "when 'partnership' is selected" do

      let(:registration) { Registration.create }

      it "sets #businessType to 'partnership' on the registration" do
        post :create, :registration => { "businessType" => "partnership" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).businessType).to eq('partnership')
      end

      it "redirects to the 'other businesses' page" do
        post :create, :registration => { "businessType" => "partnership" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :other_businesses
      end

    end

    context "when 'limitedCompany' is selected" do

      let(:registration) { Registration.create }

      it "sets #businessType to 'limitedCompany' on the registration" do
        post :create, :registration => { "businessType" => "limitedCompany" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).businessType).to eq('limitedCompany')
      end

      it "redirects to the 'other businesses' page" do
        post :create, :registration => { "businessType" => "limitedCompany" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :other_businesses
      end

    end

    context "when 'publicBody' is selected" do

      let(:registration) { Registration.create }

      it "sets #businessType to 'publicBody' on the registration" do
        post :create, :registration => { "businessType" => "publicBody" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).businessType).to eq('publicBody')
      end

      it "redirects to the 'other businesses' page" do
        post :create, :registration => { "businessType" => "publicBody" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :other_businesses
      end

    end

    context "when 'charity' is selected" do

      let(:registration) { Registration.create }

      it "sets #businessType to 'charity' on the registration" do
        post :create, :registration => { "businessType" => "charity" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).businessType).to eq('charity')
      end

      it "redirects to the 'business details' page" do
        post :create, :registration => { "businessType" => "charity" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :business_details
      end

    end

    context "when 'authority' is selected" do

      let(:registration) { Registration.create }

      it "sets #businessType to 'authority' on the registration" do
        post :create, :registration => { "businessType" => "authority" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).businessType).to eq('authority')
      end

      it "redirects to the 'business details' page" do
        post :create, :registration => { "businessType" => "authority" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :business_details
      end

    end

    context "when 'other' is selected" do

      let(:registration) { Registration.create }

      it "sets #businessType to 'other' on the registration" do
        post :create, :registration => { "businessType" => "other" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).businessType).to eq('other')
      end

      it "redirects to the 'no registration' page" do
        post :create, :registration => { "businessType" => "other" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :no_registration
      end

    end

    context "when no selection is made" do

      let(:registration) { Registration.create }

      it 'does not set #businessType' do
        post :create, :registration => { "businessType" => "" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).businessType).to eq('')
      end

      it "re-renders the 'business type' page with a HTTP status code of 400" do
        post :create, :registration => { "businessType" => "" }, reg_uuid: registration.reg_uuid
        expect(response).to render_template("show")
        expect(response.code).to eq('400')
      end

    end

  end

end
