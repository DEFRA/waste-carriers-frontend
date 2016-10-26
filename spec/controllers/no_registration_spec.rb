require 'spec_helper'

describe NoRegistrationController, :type => :controller do

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

end
