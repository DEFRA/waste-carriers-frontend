Given(/^there is an activated user$/) do
  open_email my_user.email
  current_email.click_link 'confirmation_link'
end

When(/^somebody visits the ([\w ]+) Sign In page$/) do |user_type|
  visit get_sign_in_path_for_user_type(user_type)
end

When(/^enters valid credentials$/) do
  expect(page).to have_text 'Sign in'
  fill_in 'Email', with: my_user.email
  fill_in 'Password', with: my_user.password
  click_button 'sign_in'
end

Then(/^the user should be logged in successfully$/) do
  expect(page).to have_text 'Signed in as'
end

When(/^enters invalid credentials$/) do
  expect(page).to have_text 'Sign in'
  fill_in 'Email', with: my_user.email
  fill_in 'Password', with: 'incorrect_password'
  click_button 'sign_in'
end

Then(/^the user should see a login account unlocked successfully page$/) do
  expect(page).to have_text 'Your account has been unlocked successfully'
end

Then(/^the user should see a login error$/) do
  expect(page).to have_text 'Invalid email or password.'
end

# TODO GM - still need to figure out how to switch between www and admin subdomains in Cucumber

When(/^the user tries to access the internal admin login URL from the public domain$/) do
  base_url = 'http://' + Rails.configuration.waste_exemplar_frontend_url
  url = base_url + new_user_session_path
  visit url
end

Then(/^the page is not found$/) do
  expect(current_path).to have_text /sign_in/i
end

When(/^the user tries to access the internal agency login URL from the public domain$/) do
  base_url = 'http://' + Rails.configuration.waste_exemplar_frontend_url
  url = base_url + new_agency_user_session_path
  visit url
end

When(/^the user tries to access the internal admin login URL from the admin domain$/) do
  base_url = 'http://' + Rails.configuration.waste_exemplar_frontend_admin_url
  url = base_url + new_admin_session_path
  visit url
end

Then(/^the admin login page is shown$/) do
  expect(current_path).to have_text /admins\/sign_in/i
end

When(/^the user tries to access the internal agency login URL from the admin domain$/) do
  base_url = 'http://' + Rails.configuration.waste_exemplar_frontend_admin_url
  url = base_url + new_agency_user_session_path
  visit url
end

Then(/^the agency user login page is shown$/) do
  expect(current_path).to have_text /agency_users\/sign_in/i
end

When(/^the user tries to access the user login URL from the internal admin domain$/) do
  base_url = 'http://' + Rails.configuration.waste_exemplar_frontend_admin_url
  url = base_url + new_user_session_path
  visit url
end



Given(/^an ([\w ]+) exists and has an activated, non-locked account$/) do |user_type|
  if user_type == 'External User'
    open_email my_user.email
    current_email.click_link 'confirmation_link'
  end
  expect(get_database_object_for_user_type(user_type).access_locked?).to eq(false)
end

Given(/^an External User exists but has not confirmed their account$/) do
  expect(get_database_object_for_user_type('External User').confirmed?).to eq(false)
end

When(/^the maximum number of invalid login attempts is exceeded for the ([\w ]+) account$/) do |user_type|
  emailAddress = get_factorygirl_user_for_user_type(user_type).email
  new_session_page = get_sign_in_path_for_user_type(user_type)

  maxAttempts = Devise.maximum_attempts.to_i + 1

  maxAttempts.times do
    visit new_session_page
    fill_in 'Email', with: emailAddress
    fill_in 'Password', with: 'this_is_the_wrong_password'
    click_button 'sign_in'
    expect(page).to have_text 'Invalid email or password'
  end

  expect(get_database_object_for_user_type(user_type).access_locked?).to be true
end

When(/^somebody visits the ([\w ]+) Forgot Password page$/) do |user_type|
  visit get_new_password_path_for_user_type(user_type)
end

When(/^somebody visits the ([\w ]+) Send Unlock Instructions page$/) do |user_type|
  visit get_unlock_path_for_user_type(user_type)
end

When(/^somebody visits the Resend Confirmation Instructions page$/) do
  visit new_user_confirmation_path
end

When (/^completes the request using the email address of a valid ([\w ]+)$/) do |user_type|
  fill_in 'Email', with: get_factorygirl_user_for_user_type(user_type).email
  click_button 'send_instructions_button'
end

When (/^completes the request using a guessed email address$/) do
  fill_in 'Email', with: 'a_guessed_address@example.com'
  click_button 'send_instructions_button'
end

Then(/^they should be redirected to the login page, but not told if the email address they supplied was known or unknown$/) do
  expect(current_path).to have_text(/sign_in/i)
  # Note: we can't really guarantee that the page doesn't contain ANY clues
  # about whether or not the email address exists; we limit our test to looking
  # for the key phrase "*IF* your account exists..."
  notice = find_by_id 'notice_explanation'
  expect(notice).to have_text(/if your (email address|account) exists/i)
  expect(find_field('Email').value).to be_blank
end

Then(/^the ([\w ]+) should receive an email containing a link which allows the password to be reset$/) do |user_type|
  open_email get_factorygirl_user_for_user_type(user_type).email
  expect(current_email.subject).to have_text 'Reset password instructions'
  current_email.click_link 'password_reset_link'
  expect(page).to have_css "input[id$='_password_confirmation']"
end

Then(/^the ([\w ]+) should receive an email containing a link which unlocks the account$/) do |user_type|
  open_email get_factorygirl_user_for_user_type(user_type).email
  expect(current_email.subject).to have_text 'Unlock Instructions'
  current_email.click_link 'unlock_link'
  expect(current_path).to have_text /sign_in/i
end

Then(/^the ([\w ]+) account 'locked' status should be (\w+)$/) do |user_type, expected_locked_status|
  if expected_locked_status == 'unlocked'
    expect(get_database_object_for_user_type(user_type).access_locked?).to be false
  elsif expected_locked_status == 'locked'
    expect(get_database_object_for_user_type(user_type).access_locked?).to be true
  else
    throw 'Unknown value specified for expected_locked_status'
  end
end

Then(/^the External User should receive an email allowing them to confirm their account$/) do
  open_email my_user.email
  expect(current_email.subject).to have_text 'Verify your email address'
  current_email.click_link 'confirmation_link'
  expect(get_database_object_for_user_type('External User').confirmed?).to be true
end

When(/^I am logged in as waste carrier user '([\w@\.]+)'$/) do | email|
   visit new_user_session_path
   fill_in 'Email', with: email
   fill_in 'Password', with: my_password
   click_button 'sign_in'
   expect(page).to have_xpath("//*[@id = 'external-user-signed-in']")
end

# TODO AH need to centralise date formatting and get expire date from services
Then(/^my registration Certificate has a correct Expiry Date$/) do
  expectedExpiryDate = Date.today + Rails.configuration.registration_expires_after
  first(:css, '.viewCertificate').click
  expect(page).to have_text expectedExpiryDate.strftime('%A ' + expectedExpiryDate.mday.ordinalize + ' %B %Y')
end

Then(/^my registration Certificate does not have an Expiry Date/) do
  first(:css, '.viewCertificate').click
  page.has_no_text? 'Expiry date of registration (unless revoked)'
end
