Given(/^I am on the initial page$/) do
  visit find_path
  page.should have_content 'Find out if'
end

Given(/^I click on "(.*?)"$/) do |name|
  click_on(name)
end

Then(/^I should see "(.*?)"$/) do |some_text|
  page.should have_content some_text
end

Then(/^I select business or organisation type "(.*?)"$/) do |field_value|
  page.select field_value, from: 'registration_businessType'
end

Then(/^I fill in "(.*?)" with "(.*?)"$/) do |field_name, field_value|
  fill_in field_name, with: field_value
end

Then(/^I click "(.*?)"$/) do |name|
  click_on name
end

Then(/^I fill in valid contact details$/) do
  fill_in 'sPostcode', with: 'BS1 5AH'
  click_button 'Find address'
  page.select "Environment Agency, Horizon House, Deanery Road, City Centre, Bristol BS1 5AH", from: 'sSelect'

  page.select 'Mr', from: 'registration_title'
  fill_in 'registration_firstName', with: 'Joe'
  fill_in 'registration_lastName', with: 'Bloggs'
  fill_in 'registration_phoneNumber', with: '0123 456'
  fill_in 'registration_contactEmail', with: 'joe.bloggs@example.com'
end


Then(/^I select the declaration checkbox$/) do
  find_field 'registration_declaration'
  check 'registration_declaration'
end

Then(/^I should see the Confirmation page$/) do
  page.should have_content 'is registered'
  page.should have_button 'Finished'
end

Then(/^I should see the Confirm Account page$/) do
  page.should have_content 'Follow the instructions in the email to confirm your account and complete your registration'
end

When(/^I provide valid individual trading name details$/) do
  fill_in 'registration_companyName', with: 'Joe Bloggs'
  click_on 'Next'
end

When(/^I provide valid individual trading name details including business type$/) do
  page.select 'Sole trader', from: 'registration_businessType'
  fill_in 'registration_companyName', with: 'Joe Bloggs'
  click_on 'Next'
end

When(/^I provide valid contact details$/) do
  fill_in 'sPostcode', with: 'BS1 5AH'
  click_button 'Find address'
  page.select "Environment Agency, Horizon House, Deanery Road, City Centre, Bristol BS1 5AH", from: 'sSelect'

  page.select 'Mr', from: 'registration_title'
  fill_in 'registration_firstName', with: 'Joe'
  fill_in 'registration_lastName', with: 'Bloggs'
  fill_in 'registration_phoneNumber', with: '0123 456'
  fill_in 'registration_contactEmail', with: 'joe.bloggs@example.com'
  click_on 'Next'
end

Given(/^I provide valid contact details for "(.*?)"$/) do |email|
  fill_in 'sPostcode', with: 'BS1 5AH'
  click_button 'Find address'
  page.select "Environment Agency, Horizon House, Deanery Road, City Centre, Bristol BS1 5AH", from: 'sSelect'

  page.select 'Mr', from: 'registration_title'
  fill_in 'registration_firstName', with: 'Joe'
  fill_in 'registration_lastName', with: 'Bloggs'
  fill_in 'registration_phoneNumber', with: '0123 456'
  fill_in 'registration_contactEmail', with: email
  click_on 'Next'
end

When(/^I confirm the declaration$/) do
  find_field 'registration_declaration'
  check 'registration_declaration'
  click_on 'Next'
end

When(/^I provide valid user details for sign up$/) do
  unique_email = 'test-' + SecureRandom.urlsafe_base64 + '@example.com' # TODO factory
  fill_in 'registration_accountEmail', with: unique_email
  fill_in 'registration_accountEmail_confirmation', with: unique_email
  fill_in 'registration_password', with: 'Bloggs123!'
  fill_in 'registration_password_confirmation', with: 'Bloggs123!'
end


When(/^I begin a registration$/) do
  visit '/your-registration/business-details'
end

Then(/^I should see an error with "(.*?)"$/) do |some_text|
  within(:css, "div#error_explanation") do
    page.should have_content some_text
  end
end

Then(/^I should see no error with "(.*?)"$/) do |some_text|
  within(:css, "div#error_explanation") do
    page.should_not have_content some_text
  end
end

When(/^I begin a registration as an Individual$/) do
  visit '/your-registration/business-details'
  page.select 'Sole trader', from: 'registration_businessType'
end

When(/^I fill in company name with "(.*?)"$/) do |company_name|
  fill_in 'registration_companyName', with: company_name
end

When(/^I fill in house number with "(.*?)"$/) do |house_number|
  fill_in 'registration_houseNumber', with: house_number
end

When(/^I fill in postcode with "(.*?)"$/) do |pc|
  fill_in 'registration_postcode', with: pc
end

Given(/^I have an activated account$/) do
  theUsersEmail = 'joe@example.com' # TODO factory
  theUsersPassword = 'secret123'
  user = User.find_by_email(theUsersEmail)
  if user != nil
    user.destroy
  end
  user = User.new
  user.email = theUsersEmail
  user.password = theUsersPassword
  user.password_confirmation = theUsersPassword
  user.skip_confirmation!
  user.save!

  user = User.find_by_email('joe@example.com')
  user.should be
end

Given(/^I do not have an account yet$/) do
  user = User.find_by_email('joe.bloggs@example.com') # TODO factory
  if user
    user.destroy
  end
end

Given(/^I am not logged in$/) do
  visit destroy_user_session_path
end

When(/^I provide valid user details for sign in$/) do
  fill_in 'registration_accountEmail', with: 'joe@example.com'
  fill_in 'registration_password', with: 'secret123'
end

Given(/^I am already logged in$/) do
  visit new_user_session_path
  page.should have_content 'Sign in'
  fill_in 'Email', with: 'joe@example.com' # TODO factory
  fill_in 'Password', with: 'secret123'
  click_button 'Sign in'
  page.should have_content 'Signed in as joe@example.com'
end

When(/^proceed to the Address and Contact Details page$/) do
  fill_in 'registration_companyName', with: 'Joe Bloggs'
  click_on 'Next'
end

When(/^I prepare to enter an address manually$/) do
  click_link 'I want to add an address myself'
end

Then(/^it should send me an Account Activation email$/) do
  open_email User.last.email # TODO factory
  current_email.should have_content 'Please select the link below to confirm your account'
end

Then(/^it should send a Registration Confirmation email to "(.*?)"$/) do |email_address|
  open_email email_address # TODO knows email
  current_email.subject.should == 'Waste Carrier Registration Complete'
end

Then(/^when I click on the activation link$/) do
  open_email User.last.email
  current_email.click_link 'Confirm your account'
end

Then(/^I should see the Registration Confirmed page$/) do
  page.should have_content "Registration complete"
end

Then(/^I can view the certificate$/) do
  click_on 'View certificate'
  page.should have_content 'Registered on:'
  page.should have_content 'Your registration will last indefinitely'
  click_on 'Back'
end

Then(/^I can finish and return to govuk$/) do
  click_on 'Finish'
end
