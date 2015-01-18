require 'spec_helper'

describe StartController, :type => :controller do

  describe 'GET #show' do

    it 'responds successfully with a HTTP 200 status code' do
      get :show
      expect(response.code).to eq('200')
    end

    it 'renders the #show template' do
      get :show
      expect(response).to render_template("show")
    end

  end

  describe 'POST #create' do

    before :each do
      session[:registration_id] = registration.id
      session[:editing] = true
    end

    context "when 'renew' is selected" do

      let(:registration) { Registration.create }

      it "sets #newOrRenew to 'renew' on the registration" do
        post :create, :registration => { "newOrRenew" => "renew" }
        expect(assigns(:registration).newOrRenew).to eq('renew')
      end

      it "redirects to the 'enter registration' page" do
        post :create, :registration => { "newOrRenew" => "renew" }
        expect(response).to redirect_to :enterRegistration
      end

    end

    context "when 'new' is selected" do

      let(:registration) { Registration.create }

      it "sets #newOrRenew to 'new' on the registration" do
        post :create, :registration => { "newOrRenew" => "new" }
        expect(assigns(:registration).newOrRenew).to eq('new')
      end

      it "redirects to the 'business type' page" do
        post :create, :registration => { "newOrRenew" => "new" }
        expect(response).to redirect_to :business_type
      end

    end

    context "when no selection is made" do

      let(:registration) { Registration.create }

      it 'does not set #newOrRenew' do
        post :create, :registration => { "newOrRenew" => "" }
        expect(assigns(:registration).newOrRenew).to eq('')
      end

      it "re-renders the 'start' page with a HTTP status code of 400" do
        post :create, :registration => { "newOrRenew" => "" }
        expect(response).to render_template("show")
        expect(response.code).to eq('400')
      end

    end

  end

end
