require 'spec_helper'

describe UpperRegistrationsController do

  describe "GET 'business_name'" do
    it "returns http success" do
      get 'business_name'
      response.should be_success
    end
  end

  describe "GET 'main_address'" do
    it "returns http success" do
      get 'main_address'
      response.should be_success
    end
  end

  describe "GET 'director_address'" do
    it "returns http success" do
      get 'director_address'
      response.should be_success
    end
  end

  describe "GET 'contact_detail'" do
    it "returns http success" do
      get 'contact_detail'
      response.should be_success
    end
  end

  describe "GET 'conviction'" do
    it "returns http success" do
      get 'conviction'
      response.should be_success
    end
  end

  describe "GET 'summary'" do
    it "returns http success" do
      get 'summary'
      response.should be_success
    end
  end

end
