#Registration step definitions
#Capybara syntax (visit, fill_in, ...) see e.g. https://github.com/jnicklas/capybara

Given(/^I am on the initial page$/) do
  visit "/registrations/find"
  assert page.has_content?("Waste Carrier Registration")
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
  find_field('registration_houseNumber')
  #assert(page.has_content?('Address and contact details'))
  fill_in('registration_houseNumber', :with => '12')
  fill_in('registration_streetLine1', :with => 'Deanery Road')
  fill_in('registration_townCity', :with => 'Bristol')
  fill_in('registration_postcode', :with => 'BS1 5AH')

  #click_button 'findAddress'
  #page.select('addr1', :from => 'addresses')

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
  assert(page.has_content?('has been registered'))
end


#Alternate version....


When(/^I provide valid individual trading name details$/) do
  #The registerAs field dropdown has been removed...
  #page.select('Carrier', :from => 'registration_registerAs')
  page.select('Sole trader', :from => 'registration_businessType')
  fill_in('registration_companyName', :with => 'Joe Bloggs')  
  click_on('Next')
end

When(/^I provide valid contact details$/) do
  find_field('registration_houseNumber')
  #assert(page.has_content?('Address and contact details'))
  fill_in('registration_houseNumber', :with => '12')
  fill_in('registration_streetLine1', :with => 'Some Road')
  fill_in('registration_townCity', :with => 'Some Town')
  fill_in('registration_postcode', :with => 'SW12 3AB')
  page.select('Mr', :from => 'registration_title')
  fill_in('registration_firstName', :with => 'Joe')  
  fill_in('registration_lastName', :with => 'Bloggs')  
  fill_in('registration_phoneNumber', :with => '0123 456')  
  fill_in('registration_contactEmail', :with => 'joe@bloggs.com')  
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
  fill_in('registration_accountEmail', :with => 'joe@bloggs.com')
  fill_in('registration_password', :with => 'bloggs123')
  fill_in('registration_password_confirmation', :with  => 'bloggs123')
  #click_on 'Register'
end


When(/^I begin a registration$/) do
    visit '/registrations/new'
end

Then(/^I should see an error with "(.*?)"$/) do |some_text|
  assert(page.has_content?(some_text))
end

When(/^I begin a registration as an Individual$/) do
  visit '/registrations/new'
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
  click_on "Sign in"
  assert(page.has_content? "Sign in")
  fill_in('user_email', :with => 'joe@company.com')
  fill_in('user_password', :with => 'secret123')
  click_button "Sign in"
  assert(page.has_content? "Signed in as joe@company.com")
end

When(/^proceed to the Address and Contact Details page$/) do
  page.select('Sole trader', :from => 'registration_businessType')
  fill_in('registration_companyName', :with => 'Joe Bloggs')  
  click_on('Next')
end


Then(/^it should send me a Registration Confirmation email$/) do
  @email = ActionMailer::Base.deliveries.last
  @email.to.should include "joe@bloggs.com"
  @email.subject.should include("Registration Complete for a Waste Carrier!")
end

