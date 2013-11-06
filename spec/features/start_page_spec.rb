
require "spec_helper"

describe "The Registration Start Page", :sauce => true do
  it "Should provide information on how to register" do
    visit "/registrations/start"
    page.should have_content "Register your business or organisation as a lower tier waste carrier/broker/dealer"
    click_button "Begin registration"
  end 
end