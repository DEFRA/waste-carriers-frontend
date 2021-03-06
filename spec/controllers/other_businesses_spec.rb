require 'spec_helper'

describe OtherBusinessesController, :type => :controller do

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

      it "sets #otherBusinesses to 'yes' on the registration" do
        post :create, :registration => { "otherBusinesses" => "yes" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).otherBusinesses).to eq('yes')
      end

      it "redirects to the 'other businesses' page" do
        post :create, :registration => { "otherBusinesses" => "yes" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :service_provided
      end

    end

    context "when 'no' is selected" do

      let(:registration) { Registration.create }

      it "sets #otherBusinesses to 'no' on the registration" do
        post :create, :registration => { "otherBusinesses" => "no" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).otherBusinesses).to eq('no')
      end

      it "redirects to the 'Construction/demolition' page" do
        post :create, :registration => { "otherBusinesses" => "no" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :construction_demolition
      end

    end

    context "when no selection is made" do

      let(:registration) { Registration.create }

      it 'does not set #otherBusinesses' do
        post :create, :registration => { "otherBusinesses" => "" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).otherBusinesses).to eq('')
      end

      it "re-renders the 'other businesses' page with a HTTP status code of 400" do
        post :create, :registration => { "otherBusinesses" => "" }, reg_uuid: registration.reg_uuid
        expect(response).to render_template("show")
        expect(response.code).to eq('400')
      end

    end

  end

end
