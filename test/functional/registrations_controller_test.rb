require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  setup do
    @registration = registrations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:registrations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create registration" do
    assert_difference('Registration.count') do
      post :create, registration: { address: @registration.address, companyRegistrationNumber: @registration.companyRegistrationNumber, emailAddress: @registration.emailAddress, firstName: @registration.firstName, houseNumber: @registration.houseNumber, individualsType: @registration.individualsType, lastName: @registration.lastName, organisationName: @registration.organisationName, organisationType: @registration.organisationType, phoneNumber: @registration.phoneNumber, postcode: @registration.postcode, publicBodyType: @registration.publicBodyType, registerAs: @registration.registerAs, title: @registration.title, uprn: @registration.uprn }
    end

    assert_redirected_to registration_path(assigns(:registration))
  end

  test "should show registration" do
    get :show, id: @registration
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @registration
    assert_response :success
  end

  test "should update registration" do
    put :update, id: @registration, registration: { address: @registration.address, companyRegistrationNumber: @registration.companyRegistrationNumber, emailAddress: @registration.emailAddress, firstName: @registration.firstName, houseNumber: @registration.houseNumber, individualsType: @registration.individualsType, lastName: @registration.lastName, organisationName: @registration.organisationName, organisationType: @registration.organisationType, phoneNumber: @registration.phoneNumber, postcode: @registration.postcode, publicBodyType: @registration.publicBodyType, registerAs: @registration.registerAs, title: @registration.title, uprn: @registration.uprn }
    assert_redirected_to registration_path(assigns(:registration))
  end

  test "should destroy registration" do
    assert_difference('Registration.count', -1) do
      delete :destroy, id: @registration
    end

    assert_redirected_to registrations_path
  end
end
