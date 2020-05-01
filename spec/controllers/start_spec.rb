require 'spec_helper'

describe StartController, :type => :controller do
  describe 'GET #show' do
    it "returns a 302 response and redirects to the new app journey" do
      allow(Rails.configuration).to receive(:front_office_url).and_return("http://localhost:3000/fo")

      get :show

      expect(response.code).to eq("302")
      expect(response).to redirect_to "http://localhost:3000/fo/start"
    end

    context "when the do_not_redirect params is passed in" do
      it 'responds successfully with a HTTP 200 status code' do
        get :show, do_no_redirect: 1
        expect(response.code).to eq("200")
      end

      it 'renders the #show template' do
        get :show, do_no_redirect: 1
        expect(response).to render_template("show")
      end
    end
  end

  describe 'POST #create' do

    context "when 'renew' is selected" do

      let(:registration) { Registration.create }

      it "sets #newOrRenew to 'renew' on the registration" do
        post :create, :registration => { "newOrRenew" => "renew" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).newOrRenew).to eq('renew')
      end

      it "redirects to the 'existing registration' page" do
        post :create, :registration => { "newOrRenew" => "renew" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :existing_registration
      end

    end

    context "when 'new' is selected" do

      let(:registration) { Registration.create }

      it "sets #newOrRenew to 'new' on the registration" do
        post :create, :registration => { "newOrRenew" => "new" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).newOrRenew).to eq('new')
      end

      it "redirects to the 'location' page" do
        post :create, :registration => { "newOrRenew" => "new" }, reg_uuid: registration.reg_uuid
        expect(response).to redirect_to :location
      end

    end

    context "when no selection is made" do

      let(:registration) { Registration.create }

      it 'does not set #newOrRenew' do
        post :create, :registration => { "newOrRenew" => "" }, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).newOrRenew).to eq('')
      end

      it "re-renders the 'start' page with a HTTP status code of 400" do
        post :create, :registration => { "newOrRenew" => "" }, reg_uuid: registration.reg_uuid
        expect(response).to render_template("show")
        expect(response.code).to eq('400')
      end

    end

  end

end
