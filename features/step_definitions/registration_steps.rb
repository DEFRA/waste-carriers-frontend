#Registration step definitions
#Capybara syntax (visit, fill_in, ...) see e.g. https://github.com/jnicklas/capybara

Given(/^I am on the initial page$/) do
  visit "/registrations/find"
  assert page.has_content?("Find out if")
end

Given(/^I click on "(.*?)"$/) do |name|
  click_on(name)
end

Then(/^I should see "(.*?)"$/) do |some_text|
  assert(page.has_content?(some_text))
end

Then(/^I select business or organisation type "(.*?)"$/) do |field_value|
    page.select(field_value, :from => 'registration_businessType')
end

Then(/^I fill in "(.*?)" with "(.*?)"$/) do |field_name, field_value|
  fill_in(field_name, :with => field_value)
end

Then(/^I click "(.*?)"$/) do |name|
  click_on name
end

Then(/^I fill in valid contact details$/) do

  ## With address lookup enabled and working, users do not enter house number etc. anymore
  #find_field('registration_houseNumber')
  ##assert(page.has_content?('Address and contact details'))
  #fill_in('registration_houseNumber', :with => '12')
  #fill_in('registration_streetLine1', :with => 'Deanery Road')
  #fill_in('registration_townCity', :with => 'Bristol')
  #fill_in('registration_postcode', :with => 'BS1 5AH')

  fill_in('sPostcode', :with => 'BS1 5AH')
  click_button 'Find address'
  page.select("Environment Agency, Horizon House, Deanery Road, City Centre, Bristol BS1 5AH", :from => 'sSelect')
  
  page.select('Mr', :from => 'registration_title')
  fill_in('registration_firstName', :with => 'Joe')  
  fill_in('registration_lastName', :with => 'Bloggs')  
  fill_in('registration_phoneNumber', :with => '0123 456')  
  fill_in('registration_contactEmail', :with => 'joe@bloggs.com')  
end


Then(/^I select the declaration checkbox$/) do
  find_field('registration_declaration')
  check('registration_declaration')
end

Then(/^I should see the Confirmation page$/) do
  assert(page.has_content?('is registered'), 'Cannot find \'has been registered\' text')
  assert(page.has_button?('Finished'), 'Cannot find finish button')
end


#Alternate version....


When(/^I provide valid individual trading name details$/) do
  #page.select('Sole trader', :from => 'registration_businessType')
  fill_in('registration_companyName', :with => 'Joe Bloggs')  
  click_on('Next')
end

When(/^I provide valid individual trading name details including business type$/) do
  page.select('Sole trader', :from => 'registration_businessType')
  fill_in('registration_companyName', :with => 'Joe Bloggs')  
  click_on('Next')
end

When(/^I provide valid contact details$/) do
  #find_field('registration_houseNumber')
  ##assert(page.has_content?('Address and contact details'))
  #fill_in('registration_houseNumber', :with => '12')
  #fill_in('registration_streetLine1', :with => 'Some Road')
  #fill_in('registration_townCity', :with => 'Some Town')
  #fill_in('registration_postcode', :with => 'SW12 3AB')

  fill_in('sPostcode', :with => 'BS1 5AH')
  click_button 'Find address'
  page.select("Environment Agency, Horizon House, Deanery Road, City Centre, Bristol BS1 5AH", :from => 'sSelect')

  page.select('Mr', :from => 'registration_title')
  fill_in('registration_firstName', :with => 'Joe')  
  fill_in('registration_lastName', :with => 'Bloggs')  
  fill_in('registration_phoneNumber', :with => '0123 456')  
  fill_in('registration_contactEmail', :with => 'joe@bloggs.com')  
  click_on('Next')
  #assert(page.has_content?('Check details and register'))
end

Given(/^I provide valid contact details for "(.*?)"$/) do |email|
  #find_field('registration_houseNumber')
  ##assert(page.has_content?('Address and contact details'))
  #fill_in('registration_houseNumber', :with => '12')
  #fill_in('registration_streetLine1', :with => 'Some Road')
  #fill_in('registration_townCity', :with => 'Some Town')
  #fill_in('registration_postcode', :with => 'SW12 3AB')
  fill_in('sPostcode', :with => 'BS1 5AH')
  click_button 'Find address'
  page.select("Environment Agency, Horizon House, Deanery Road, City Centre, Bristol BS1 5AH", :from => 'sSelect')

  page.select('Mr', :from => 'registration_title')
  fill_in('registration_firstName', :with => 'Joe')  
  fill_in('registration_lastName', :with => 'Bloggs')  
  fill_in('registration_phoneNumber', :with => '0123 456')  
  fill_in('registration_contactEmail', :with => email)  
  click_on('Next')
  #assert(page.has_content?('Check details and register'))
end

When(/^I confirm the declaration$/) do
  find_field('registration_declaration')
  check('registration_declaration')
  click_on 'Next'
end

When(/^I provide valid user details for sign up$/) do
  #page.select('Sign up (new e-mail)', :from => 'registration_sign_up_mode')
  unique_email = 'test-' + SecureRandom.urlsafe_base64 + '@bloggs.com'
  fill_in('registration_accountEmail', :with => unique_email)
  fill_in('registration_accountEmail_confirmation', :with => unique_email)
  fill_in('registration_password', :with => 'bloggs123')
  fill_in('registration_password_confirmation', :with  => 'bloggs123')
  #click_on 'Register'
end


When(/^I begin a registration$/) do
    visit '/your-registration/business-details'
end

Then(/^I should see an error with "(.*?)"$/) do |some_text|
  assert(page.has_content?(some_text))
end

When(/^I begin a registration as an Individual$/) do
  visit '/your-registration/business-details'
  page.select('Sole trader', :from => 'registration_businessType')
end

When(/^I fill in company name with "(.*?)"$/) do |company_name|
  fill_in('registration_companyName', :with => company_name)  
end

When(/^I fill in house number with "(.*?)"$/) do |house_number|
  fill_in('registration_houseNumber', :with => house_number)  
end

When(/^I fill in postcode with "(.*?)"$/) do |pc|
  fill_in('registration_postcode', :with => pc)
end

Given(/^I have an account$/) do
  theUsersEmail = 'joe@company.com'
  theUsersPassword = 'secret123'
  if !User.find_by_email(theUsersEmail)
    user = User.new
    user.email = theUsersEmail
    user.password = theUsersPassword
    user.password_confirmation = theUsersPassword
    user.save!
  end

  user = User.find_by_email('joe@company.com')
  assert(user, 'We need the User in the database')
end

Given(/^I do not have an account yet$/) do
    user = User.find_by_email('joe@bloggs.com')
    if user
      user.destroy
    end
end

Given(/^I am not logged in$/) do
  #Note: Logging out via DELETE (vs. GET) - therefore visiting the URL is not enough
  #visit('/users/sign_out')
  if (page.has_content?("Logged in as"))
    click_button("Logout")
  end
  assert(!page.has_content?("Logged in as"))
end

When(/^I provide valid user details for sign in$/) do
  fill_in('registration_accountEmail', :with => 'joe@company.com')
  fill_in('registration_password', :with => 'secret123')
end

Given(/^I am already logged in$/) do
  #click_on "Sign in"
  visit '/users/sign_in'
  assert(page.has_content? "Sign in")
  fill_in('user_email', :with => 'joe@company.com')
  fill_in('user_password', :with => 'secret123')
  click_button "Sign in"
  assert(page.has_content? "Signed in as joe@company.com")
end

When(/^proceed to the Address and Contact Details page$/) do
  #page.select('Sole trader', :from => 'registration_businessType')
  fill_in('registration_companyName', :with => 'Joe Bloggs')  
  click_on('Next')
end

When(/^I prepare to enter an address manually$/) do
  ## At least at the moment the user has to perform a search in order to make the link appear
  fill_in('sPostcode', :with => 'BS1 5AH')
  click_button 'Find address'
  click_link "I want to add an address myself"
end

Then(/^it should send me a Registration Confirmation email$/) do
  @email = ActionMailer::Base.deliveries.last
  #TODO: verify random e-mail address created above
  @email.to.first.should include '@bloggs.com'
  @email.subject.should include "Waste Carrier Registration Complete"
end

