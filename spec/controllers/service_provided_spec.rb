require 'spec_helper'

describe ServiceProvidedController, :type => :controller do

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

      it "sets #isMainService to 'yes' on the registration" do
        post :create, :registration => { "isMainService" => "yes" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).isMainService).to eq('yes')
      end

      it "redirects to the 'other businesses' page" do
        post :create, :registration => { "isMainService" => "yes" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :only_deal_with
      end

    end

    context "when 'no' is selected" do

      let(:registration) { Registration.create }

      it "sets #isMainService to 'no' on the registration" do
        post :create, :registration => { "isMainService" => "no" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).isMainService).to eq('no')
      end

      it "redirects to the 'Construction/demolition' page" do
        post :create, :registration => { "isMainService" => "no" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :construction_demolition
      end

    end

    context "when no selection is made" do

      let(:registration) { Registration.create }

      it 'does not set #isMainService' do
        post :create, :registration => { "isMainService" => "" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).isMainService).to eq('')
      end

      it "re-renders the 'is main service' page with a HTTP status code of 400" do
        post :create, :registration => { "isMainService" => "" }, reg_uuid: registration.reg_uuid
        expect(response).to render_template("show")
        expect(response.code).to eq('400')
      end

    end

  end

end
