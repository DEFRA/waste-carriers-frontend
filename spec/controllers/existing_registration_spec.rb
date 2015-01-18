require 'spec_helper'

describe ExistingRegistrationController, :type => :controller do

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

    context "when an existing 'IR' registration no. is entered" do

      let(:registration) { Registration.create }

      it "sets #originalRegistrationNumber to 'CB/AE8888XX/A001' on the registration" do
        post :create, :registration => { "originalRegistrationNumber" => "CB/AE8888XX/A001" }
        expect(assigns(:registration).originalRegistrationNumber).to eq('CB/AE8888XX/A001')
      end

      it "redirects to the 'business type' page" do
        pending("a solution to populating IR data during tests")
        post :create, :registration => { "originalRegistrationNumber" => "CB/AE8888XX/A001" }
        expect(response).to redirect_to :business_type
      end

    end

    context "when an existing 'Upper tier' registration no. is entered" do

      let(:registration) { Registration.create }

      it "sets #originalRegistrationNumber to 'CBDU1' on the registration" do
        post :create, :registration => { "originalRegistrationNumber" => "CBDU1" }
        expect(assigns(:registration).originalRegistrationNumber).to eq('CBDU1')
      end

      it "redirects to the 'User sign in' page" do
        pending("a solution to populating registration data during tests")
        post :create, :registration => { "originalRegistrationNumber" => "CBDU1" }
        expect(response).to redirect_to :new_user_session
      end

    end

  end

end
