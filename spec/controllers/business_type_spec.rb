require 'spec_helper'

describe BusinessTypeController, :type => :controller do

  describe 'GET #show' do

    it 'responds successfully with an HTTP 200 status code' do
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

    context "when 'sole trader' is selected" do

      let(:registration) { Registration.create }

      it 'sets #businessType on the registration' do
        post :create, :registration => { "businessType" => "soleTrader" }
        expect(assigns(:registration).businessType).to eq('soleTrader')
      end

      it "redirects to the 'other businesses' page" do
        post :create, :registration => { "businessType" => "soleTrader" }
        expect(response).to redirect_to :newOtherBusinesses
      end

    end

  end

end
