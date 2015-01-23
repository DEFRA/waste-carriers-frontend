require 'spec_helper'

describe ServiceProvidedController, :type => :controller do

  before :each do
    session[:registration_id] = registration.id
    session[:editing] = true
  end

  describe 'GET #show' do

    let(:registration) { Registration.create }

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

    context "when 'yes' is selected" do

      let(:registration) { Registration.create }

      it "sets #isMainService to 'yes' on the registration" do
        post :create, :registration => { "isMainService" => "yes" }
        expect(assigns(:registration).isMainService).to eq('yes')
      end

      it "redirects to the 'other businesses' page" do
        post :create, :registration => { "isMainService" => "yes" }
        expect(response).to redirect_to :newOnlyDealWith
      end

    end

    context "when 'no' is selected" do

      let(:registration) { Registration.create }

      it "sets #isMainService to 'no' on the registration" do
        post :create, :registration => { "isMainService" => "no" }
        expect(assigns(:registration).isMainService).to eq('no')
      end

      it "redirects to the 'Construction/demolition' page" do
        post :create, :registration => { "isMainService" => "no" }
        expect(response).to redirect_to :construction_demolition
      end

    end

    context "when no selection is made" do

      let(:registration) { Registration.create }

      it 'does not set #isMainService' do
        post :create, :registration => { "isMainService" => "" }
        expect(assigns(:registration).isMainService).to eq('')
      end

      it "re-renders the 'is main service' page with a HTTP status code of 400" do
        post :create, :registration => { "isMainService" => "" }
        expect(response).to render_template("show")
        expect(response.code).to eq('400')
      end

    end

  end

end
