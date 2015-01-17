require 'spec_helper'

describe OtherBusinessesController, :type => :controller do

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

      it "sets #otherBusinesses to 'yes' on the registration" do
        post :create, :registration => { "otherBusinesses" => "yes" }
        expect(assigns(:registration).otherBusinesses).to eq('yes')
      end

      it "redirects to the 'other businesses' page" do
        post :create, :registration => { "otherBusinesses" => "yes" }
        expect(response).to redirect_to :newServiceProvided
      end

    end

    context "when 'no' is selected" do

      let(:registration) { Registration.create }

      it "sets #otherBusinesses to 'no' on the registration" do
        post :create, :registration => { "otherBusinesses" => "no" }
        expect(assigns(:registration).otherBusinesses).to eq('no')
      end

      it "redirects to the 'Construction/demolition' page" do
        post :create, :registration => { "otherBusinesses" => "no" }
        expect(response).to redirect_to :newConstructionDemolition
      end

    end

  end

end
