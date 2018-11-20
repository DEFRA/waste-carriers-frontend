require 'spec_helper'

describe RegistrationsController, :type => :controller do
  let(:registration) { Registration.create }

  describe "GET #account_mode" do
    let(:default_email) { "default@example.com" }
    before do
      allow(Rails.configuration).to receive(:assisted_digital_account_email).and_return(default_email)
    end

    context "when an agency_user is signed in" do
      let(:agency_user) { AgencyUser.create }
      before do
        allow_any_instance_of(RegistrationsController).to receive(:agency_user_signed_in?).and_return(true)
        allow_any_instance_of(RegistrationsController).to receive(:current_agency_user).and_return(agency_user)
        allow_any_instance_of(Registration).to receive(:initialize_sign_up_mode).and_return("sign_in")
      end

      it "assigns the default email to the accountEmail" do
        get :account_mode, reg_uuid: registration.reg_uuid
        expect(assigns(:registration).accountEmail).to eq(default_email)
      end
    end
  end
end
