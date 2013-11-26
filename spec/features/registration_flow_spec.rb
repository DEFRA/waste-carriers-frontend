
require "spec_helper"

describe "The Registration flow", :sauce => true do
  it "The start page should provide information on whether I need to register" do
    visit "/registrations/find"
    page.should have_content "Find out if you need to register and which category applies"
    page.select('Sole trader', :from => 'discover_businessType')
    choose 'discover_otherBusinesses_no'
    choose 'discover_constructionWaste_no'
    check 'discover_wasteType_other'
    click_button "register_lower_tier"
    page.should have_content "Business or organisation details"
  end 

  it "When I fill in valid business details I should be forwarded to the contact details page" do
    page.should have_content "Business or organisation details"
    page.select('Sole trader', :from => 'registration_businessType')
    fill_in('registration_companyName', :with => 'Browser Test & Co')  
    click_on('Next')
    page.should have_content "Address and contact details"
  end

  it "When I fill in valid address and contact details I should be forwarded to the declaration page" do
    page.should have_content "Address and contact details"
    fill_in('registration_houseNumber', :with => '12')
    fill_in('registration_streetLine1', :with => 'Deanery Road')
    fill_in('registration_townCity', :with => 'Bristol')
    fill_in('registration_postcode', :with => 'BS1 5AH')
    page.select('Mr', :from => 'registration_title')
    fill_in('registration_firstName', :with => 'Joe')  
    fill_in('registration_lastName', :with => 'Bloggs')  
    fill_in('registration_phoneNumber', :with => '0123 456')  
    fill_in('registration_contactEmail', :with => 'joe@bloggs.com')    
  	click_on('Next')
    page.should have_content "Check details"
  end

  it "When I accept the declaration I should be asked to provide account details" do
    page.should have_content "Check details"
  	find_field('registration_declaration')
    check('registration_declaration')
    click_on 'Next'
    page.should have_content "Complete registration"
  end

  it "When I provide valid account details I should be able to complete the registration" do
  end

end