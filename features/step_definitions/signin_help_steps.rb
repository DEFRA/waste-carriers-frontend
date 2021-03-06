# ---- User creation steps ----

Given(/^I am a Waste Carrier visiting the service for the first time$/) do
  @this_test_email = 'new_user@example.org'
  @this_test_password = my_password
  @resource_name = :user
end

Given(/^I am a Waste Carrier and already have an account with a confirmed email address$/) do
  registration = create_complete_lower_tier_reg('Charity_LT_online_complete')
  expect(registration['metaData']['status']).to eq("ACTIVE")
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

Then(/^I should be sent to the mid\-registration User Sign In page$/) do
  expect(URI.parse(current_url).path).to eq(signin_path(reg_uuid: @registration_uuid))
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

Then(/^there should be a link to request account unlock instructions$/) do
  expect(page).to have_selector(:id, 'unlock_instructions_help')
  expect(page).to have_selector(:link, 'unlock_instructions_link')
end

# ---- Use various Sign In help elements ----

When(/^I request Password Reset instructions$/) do
  click_link('password_reset_link')
  fill_in "#{@resource_name}_email", with: @this_test_email
  click_button 'send_instructions_button'
end

When(/^I request Account Confirmation instructions$/) do
  click_link('confirmation_instructions_link')
  fill_in "#{@resource_name}_email", with: @this_test_email
  click_button 'send_instructions_button'
end

When(/^I request Account Unlock instructions$/) do
  click_link('unlock_instructions_link')
  fill_in "#{@resource_name}_email", with: @this_test_email
  click_button 'send_instructions_button'
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
  expect(page).to have_text 'Registration complete'

  visit page_before_opening_email
end

# ---- Perform a new registration ----

When(/^I make a new registration and progress as far as accepting the Declaration$/) do
  visit start_path

  choose 'registration_newOrRenew_new'
  click_button 'continue'

  choose 'registration_location_england'
  click_button 'continue'

  choose 'registration_businessType_charity'
  click_button 'continue'

  click_link 'manual_uk_address'
  fill_in 'registration_companyName', with: 'Test Charity'
  fill_in 'address_houseNumber', with: 'Horizon House'
  fill_in 'address_addressLine1', with: 'Deanery Road'
  fill_in 'address_addressLine2', with: 'EA Building'
  fill_in 'address_townCity', with: 'Bristol'
  fill_in 'address_postcode', with: 'BS1 5AH'
  click_button 'continue'

  fill_in 'registration_firstName', with: 'Firstname'
  fill_in 'registration_lastName', with: 'Surname'
  fill_in 'registration_phoneNumber', with: '0123 456 7890'
  fill_in 'registration_contactEmail', with: @this_test_email
  click_button 'continue'

  postal_address_page_complete_form

  @registration_uuid = URI.parse(current_url).path.split('/')[2]

  check 'registration_declaration'
  click_button 'confirm'
end

When(/^I complete my first registration but do not confirm my email address$/) do
  step 'I make a new registration and progress as far as accepting the Declaration'

  fill_in 'registration_accountEmail', with: @this_test_email
  fill_in 'registration_accountEmail_confirmation', with: @this_test_email
  fill_in 'registration_password', with: @this_test_password
  fill_in 'registration_password_confirmation', with: @this_test_password
  click_button 'continue'
  expect(URI.parse(current_url).path).to eq(pending_path(reg_uuid: @registration_uuid))
end
