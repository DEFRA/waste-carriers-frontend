
require "spec_helper"

describe "The Registration Start Page", :sauce => true do
  it "Should provide information on whether I need to register" do
    visit "/registrations/find"
    page.should have_content "Find out if you need to register and which category applies"
  end 
end