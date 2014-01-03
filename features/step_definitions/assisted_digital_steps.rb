## step definitions for Assisted Digital users and registrations

Given(/^I have an NCCC agency user account$/) do
  if !AgencyUser.where(email: 'test.user@agency.gov.uk').exists?
    user = AgencyUser.new
    user.email = 'test.user@agency.gov.uk'
    user.password = 'secret123'
    user.save!
  end
end

Given(/^I am logged in as an NCCC agency user$/) do
  visit "/agency_users/sign_in"
  assert(page.has_content? "Sign in")
  assert(page.has_content? "NCCC agency login")
  fill_in('agency_user_email', :with => 'test.user@agency.gov.uk')
  fill_in('agency_user_password', :with => 'secret123')
  click_button "Sign in"
  assert page.has_content?("Signed in as agency user test.user@agency.gov.uk")
end

Given(/^I have received a call from a business$/) do
	#Nothing to do here
end

Given(/^I start a new registration$/) do
  visit "/registrations"
  click_button "New registration"
end

Then(/^I should see the Business or Organisation Details page$/) do
  assert page.has_content? "Business or organisation details"
end

Then(/^I fill in valid contact details without email$/) do
  #fill_in('registration_houseNumber', :with => '12a')
  #fill_in('registration_streetLine1', :with => 'Assisted Road')
  #fill_in('registration_townCity', :with => 'Assist Town')
  #fill_in('registration_postcode', :with => 'AS1 2AB')
  fill_in('sPostcode', :with => 'BS1 5AH')
  click_button 'Find address'
  page.select("Environment Agency, Horizon House, Deanery Road, City Centre, Bristol BS1 5AH", :from => 'sSelect')

  page.select('Mr', :from => 'registration_title')
  fill_in('registration_firstName', :with => 'Antony')  
  fill_in('registration_lastName', :with => 'Assist')  
  fill_in('registration_phoneNumber', :with => '0234 567')  
  click_on('Next')
end

Then(/^the registration confirmation email should not be sent$/) do
  ActionMailer::Base.deliveries.size.should eq 0
end

Then(/^when I access the print page$/) do
  click_button "View certificate"
end

Then(/^the print page contains the six-digit access code for the user$/) do
  assert page.has_content? "access code"
  accessCode = page.find_by_id 'accessCode'
  assert accessCode.text.length == 6
end
