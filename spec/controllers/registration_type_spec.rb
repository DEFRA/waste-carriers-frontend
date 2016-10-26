require 'spec_helper'

describe RegistrationTypeController, :type => :controller do

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

  describe 'GET #edit' do

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

    context "when 'carrier_dealer' is selected" do

      let(:registration) { Registration.create }

      it "sets #registrationType to 'carrier_dealer' on the registration" do
        post :create, :registration => { "registrationType" => "carrier_dealer" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).registrationType).to eq('carrier_dealer')
      end

      it "redirects to the 'Business details' page" do
        post :create, :registration => { "registrationType" => "carrier_dealer" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :business_details
      end

      context "and edit has been selected from the confirmation page" do

        before :each do
          session[:edit_link_reg_type] = registration.reg_uuid
        end

        it "redirects to the 'Confirmation' page" do
          post :create, :registration => { "registrationType" => "carrier_dealer" }, reg_uuid: registration.reg_uuid
          expect(response).to redirect_to :declaration
        end

      end

    end

    context "when 'broker_dealer' is selected" do

      let(:registration) { Registration.create }

      it "sets #registrationType to 'broker_dealer' on the registration" do
        post :create, :registration => { "registrationType" => "broker_dealer" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).registrationType).to eq('broker_dealer')
      end

      it "redirects to the 'Business details' page" do
        post :create, :registration => { "registrationType" => "broker_dealer" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :business_details
      end

      context "and edit has been selected from the confirmation page" do

        before :each do
          session[:edit_link_reg_type] = registration.reg_uuid
        end

        it "redirects to the 'Confirmation' page" do
          post :create, :registration => { "registrationType" => "carrier_dealer" }, reg_uuid: registration.reg_uuid
          expect(response).to redirect_to :declaration
        end

      end

    end

    context "when 'carrier_broker_dealer' is selected" do

      let(:registration) { Registration.create }

      it "sets #registrationType to 'carrier_broker_dealer' on the registration" do
        post :create, :registration => { "registrationType" => "carrier_broker_dealer" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).registrationType).to eq('carrier_broker_dealer')
      end

      it "redirects to the 'Business details' page" do
        post :create, :registration => { "registrationType" => "carrier_broker_dealer" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :business_details
      end

      context "and edit has been selected from the confirmation page" do

        before :each do
          session[:edit_link_reg_type] = registration.reg_uuid
        end

        it "redirects to the 'Confirmation' page" do
          post :create, :registration => { "registrationType" => "carrier_dealer" }, reg_uuid: registration.reg_uuid
          expect(response).to redirect_to :declaration
        end

      end

    end

    context "when no selection is made" do

      let(:registration) { Registration.create }

      it 'does not set #registrationType' do
        post :create, :registration => { "registrationType" => "" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).registrationType).to eq('')
      end

      it "re-renders the 'registration type' page with a HTTP status code of 400" do
        post :create, :registration => { "registrationType" => "" }, reg_uuid: registration.reg_uuid
        expect(response).to render_template("show")
        expect(response.code).to eq('400')
      end

    end

  end

end
