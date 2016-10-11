require 'spec_helper'

describe PostalAddressController, type: :controller do

  describe 'GET #show' do
    let(:registration) { Registration.ctor }

    it 'responds successfully with a HTTP 200 status code' do
      get :show
      expect(response.code).to eq('200')
    end

    it 'renders the #show template' do
      get :show
      expect(response).to render_template('show')
    end
  end

  describe 'POST #create' do
    let(:registration) { Registration.ctor }

    context 'when mandatory fields are left bank' do
      it 'does not set #firstName' do
        post :create, address: { addressType: 'POSTAL', firstName: '' }
        expect(assigns(:address).firstName).to eq('')
      end

      it "re-renders the 'existing registration' page with a HTTP/
        status code of 400" do
        post :create, address: { addressType: 'POSTAL' }
        expect(response).to render_template('show')
        expect(response.code).to eq('400')
      end
    end

    context 'when completing a new lower tier registration' do
      it 'redirects to confirmation_path' do
        post :create,
             registration: {
               tier: 'LOWER'
             },
             address: {
               firstName: 'Joe',
               lastName: 'Grades',
               addressLine1: 'Broad Street'
             }
        expect(response).to redirect_to :newConfirmation
      end
    end

    context 'when completing a new upper tier registration' do
      it 'redirects to registration_key_people_path' do
        post :create,
             registration: {
               tier: 'UPPER'
             },
             address: {
               firstName: 'Joe',
               lastName: 'Grades',
               addressLine1: 'Broad Street'
             }
        expect(response).to redirect_to :registration_key_people
      end
    end

    context 'when edit has been selected from the confirmation page' do
      before :each do
        session[:edit_link_postal_address] = @registration.reg_uuid
      end

      it "redirects to the 'Confirmation' page" do
        post :create,
             registration: {
               tier: 'UPPER'
             },
             address: {
               firstName: 'Joe',
               lastName: 'Grades',
               addressLine1: 'Broad Street'
             }
        expect(response).to redirect_to :newConfirmation
      end
    end
  end
end
