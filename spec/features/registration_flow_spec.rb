
require "spec_helper"

describe "The Registration flow", :sauce => true do
  it "The user should be able to go through the registration flow" do
    visit "/registrations/find"
    page.should have_content "Find out if you need to register and which category applies"
    page.select('Sole trader', :from => 'discover_businessType')
    choose 'discover_otherBusinesses_no'
    choose 'discover_constructionWaste_no'
    click_button "register_lower_tier"

    page.should have_content "Business or organisation details"
    #page.select('Sole trader', :from => 'registration_businessType')
    fill_in('registration_companyName', :with => 'Browser Test & Co')  
    click_on('Next')
 
    unique_email = 'test-' + SecureRandom.urlsafe_base64 + '@example.com'

    page.should have_content "Address and contact details"
    fill_in('registration_houseNumber', :with => '12')
    fill_in('registration_streetLine1', :with => 'Deanery Road')
    fill_in('registration_townCity', :with => 'Bristol')
    fill_in('registration_postcode', :with => 'BS1 5AH')
    page.select('Mr', :from => 'registration_title')
    fill_in('registration_firstName', :with => 'Joe')  
    fill_in('registration_lastName', :with => 'Bloggs')  
    fill_in('registration_phoneNumber', :with => '0123 456')  
    fill_in('registration_contactEmail', :with => unique_email)    
  	click_on('Next')

    page.should have_content "Check your details"
  	find_field('registration_declaration')
    check('registration_declaration')
    click_on 'Next'
    
    page.should have_content "Complete registration"
    fill_in('registration_accountEmail', :with => unique_email)
    fill_in('registration_accountEmail_confirmation', :with => unique_email)
    fill_in('registration_password', :with => 'MySecret123')
    fill_in('registration_password_confirmation', :with  => 'MySecret123')
    click_on 'Complete registration'

    page.should have_content "Registration complete"
    click_on "Finish"

  end

end