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

  # describe 'POST #create' do
  #   context "when 'sole trader' is selected" do
  #     # it 'sets #businessType on the registration' do
  #     # end
  #     it "redirects to the 'other businesses' page" do
  #       post :create, registration: Registration.ctor
  #     end
  #   end
  #
  #
  #   # context 'with valid attributes' do
  #   #
  #   #
  #   # end
  #   #
  #   # context 'with invalid attributes' do
  #   #
  #   # end
  # end

end
