# ---- User creation steps ----

Given(/^I am a Waste Carrier visiting the service for the first time$/) do
  @this_test_email = 'new_user@example.org'
  @this_test_password = my_password
  @resource_name = :user
end

Given(/^I am a Waste Carrier and already have an account with a confirmed email address$/) do
  registration = create_complete_lower_tier_reg('Charity_LT_online_complete')
  assert_equal "ACTIVE", registration['metaData']['status']
  @this_test_email = registration['accountEmail']
  @this_test_password = my_password
  @resource_name = :user
end

Given(/^I am an Agency User$/) do
  @this_test_email = my_agency_user.email
  @this_test_password = agency_password
  @resource_name = :agency_user
end

Given(/^I am an Admin$/) do
  @this_test_email = my_admin.email
  @this_test_password = agency_password
  @resource_name = :admin
end



# ---- Starting points ----

When(/^I go to my sign\-in page$/) do
  visit eval("new_#{@resource_name}_session_path")
end

Given(/^I am not currently signed\-in to the service$/) do
  # noop (step exists for readability of the feature only)
end



# ---- Assert that we end up on the expected page ----

Then(/^I should be sent to the normal User Sign In page$/) do
  expect(URI.parse(current_url).path).to eq(new_user_session_path)
end

Then(/^I should be sent to the mid\-registration User Sign In page$/) do
  expect(URI.parse(current_url).path).to eq(newSignin_path)
end

Then(/^I should be sent to the normal Agency User Sign In page$/) do
  expect(URI.parse(current_url).path).to eq(new_agency_user_session_path)
end

Then(/^I should be sent to the normal Admin Sign In page$/) do
  expect(URI.parse(current_url).path).to eq(new_admin_session_path)
end



# ---- Assert that the page contains various Sign In help elements ----

Then(/^there should be a link to request password reset instructions$/) do
  expect(page).to have_selector(:id, 'password_reset_help')
  expect(page).to have_selector(:link, 'password_reset_link')
end

Then(/^there should be a link to request account confirmation instructions$/) do
  expect(page).to have_selector(:id, 'confirmation_instructions_help')
  expect(page).to have_selector(:link, 'confirmation_instructions_link')
end

Then(/^there should be a link to request account unlock instructions$/) do
  expect(page).to have_selector(:id, 'unlock_instructions_help')
  expect(page).to have_selector(:link, 'unlock_instructions_link')
end

Then(/^the NCCC contract number (should|should not) be shown$/) do |should|
  if should.eql?('should')
    expect(page).to have_selector(:id, 'unknown_email_help')
    expect(page).to have_content 'contact our helpline'
  else
    expect(page).not_to have_selector(:id, 'unknown_email_help')
    expect(page).not_to have_content 'contact our helpline'
  end
end



# ---- Use various Sign In help elements ----

When(/^I request Password Reset instructions$/) do
  click_link('password_reset_link')
  fill_in "#{@resource_name}_email", with: @this_test_email
  click_button 'send'
end

When(/^I request Account Confirmation instructions$/) do
  click_link('confirmation_instructions_link')
  fill_in "#{@resource_name}_email", with: @this_test_email
  click_button 'send'
end

When(/^I request Account Unlock instructions$/) do
  click_link('unlock_instructions_link')
  fill_in "#{@resource_name}_email", with: @this_test_email
  click_button 'send'
end

When(/^I update my password$/) do
  page_before_opening_email = current_url
  
  open_email @this_test_email
  expect(current_email.subject).to have_content 'password'
  current_email.click_link 'password_reset_link'
  expect(URI.parse(current_url).path).to eq(edit_user_password_path)
  @this_test_password = 'NewPassword789'
  fill_in 'user_password', with: @this_test_password
  fill_in 'user_password_confirmation', with: @this_test_password
  click_button 'change_password_button'
  expect(URI.parse(current_url).path).to eq(mid_registration_password_changed_path)
  
  visit page_before_opening_email
end



# ---- Interact with emails sent to the user ----

When(/^I delete all of my emails$/) do
  open_email @this_test_email
  clear_emails
  expect(all_emails).to be_empty
end

Then(/^I should recieve an email informing me that my email address is already confirmed and that I should continue with the registration$/) do
  open_email @this_test_email
  expect(current_email).to have_selector(:id, 'account_already_confirmed_email')
  expect(current_email).to have_selector(:id, 'continue_registration_paragraph')
  expect(current_email).not_to have_selector(:link, 'sign_in_link')
end

Then(/^I should recieve an email containing account confirmation instructions$/) do
  open_email @this_test_email
  expect(current_email).to have_selector(:id, 'confirmation_instructions_email')
  expect(current_email).to have_selector(:link, 'confirmation_link')
end

When(/^I confirm my my account, then close the browser window$/) do
  page_before_opening_email = current_url
  
  open_email @this_test_email
  current_email.click_link 'confirmation_link'
  expect(page).to have_content 'Registration complete'
  
  visit page_before_opening_email
end



# ---- Perform a new registration ----

When(/^I make a new registration and progress as far as accepting the Declaration$/) do
  visit start_path
  
  choose 'registration_newOrRenew_new'
  click_button 'continue'

  choose 'registration_businessType_charity'
  click_button 'continue'

  click_link 'manual_uk_address'
  fill_in 'registration_companyName', with: 'Test Charity'
  fill_in 'registration_houseNumber', with: 'Horizon House'
  fill_in 'registration_streetLine1', with: 'Deanery Road'
  fill_in 'registration_streetLine2', with: 'EA Building'
  fill_in 'registration_townCity', with: 'Bristol'
  fill_in 'registration_postcode', with: 'BS1 5AH'
  click_button 'continue'

  fill_in 'registration_firstName', with: 'Firstname'
  fill_in 'registration_lastName', with: 'Surname'
  fill_in 'registration_phoneNumber', with: '0123 456 7890'
  fill_in 'registration_contactEmail', with: @this_test_email
  click_button 'continue'

  check 'registration_declaration'
  click_button 'confirm'
end

Then(/^I should be able to continue with my registration$/) do
  fill_in 'registration_password', with: @this_test_password
  click_button 'continue'
  
  expect(URI.parse(current_url).path).to eq(finish_path)
  expect(page).to have_content 'Registration complete'
  click_button 'finished_btn'
  
  expect(page).to have_selector(:id, 'external-user-signed-in')
end

When(/^I complete my first registration but do not confirm my email address$/) do
  step 'I make a new registration and progress as far as accepting the Declaration'
  
  fill_in 'registration_accountEmail', with: @this_test_email
  fill_in 'registration_accountEmail_confirmation', with: @this_test_email
  fill_in 'registration_password', with: @this_test_password
  fill_in 'registration_password_confirmation', with: @this_test_password
  click_button 'continue'
  expect(URI.parse(current_url).path).to eq(pending_path)
end
