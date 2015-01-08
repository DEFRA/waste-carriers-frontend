Given(/^there is an activated user$/) do
  open_email my_user.email
  current_email.click_link 'confirmation_link'
end

When (/^the user visits the login page$/) do
  visit new_user_session_path
end

When(/^enters valid credentials$/) do
  page.should have_content 'Sign in'
  fill_in 'Email', with: my_user.email
  fill_in 'Password', with: my_user.password
  click_button 'sign_in_button'
end

Then(/^the user should be logged in successfully$/) do
  page.should have_content 'Signed in as'
end

When(/^enters invalid credentials$/) do
  page.should have_content 'Sign in'
  fill_in 'Email', with: my_user.email
  fill_in 'Password', with: 'incorrect_password'
  click_button 'sign_in_button'
end

Then(/^the user should see a login error$/) do
  page.should have_content 'Invalid email or password.'
end

# TODO GM - still need to figure out how to switch between www and admin subdomains in Cucumber

When(/^the user tries to access the internal admin login URL from the public domain$/) do
  base_url = 'http://' + Rails.configuration.waste_exemplar_frontend_url
  url = base_url + new_user_session_path
  visit url
end

Then(/^the page is not found$/) do
  current_path.should_not match /sign_in/i
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
  current_path.should match /admins\/sign_in/i
end

When(/^the user tries to access the internal agency login URL from the admin domain$/) do
  base_url = 'http://' + Rails.configuration.waste_exemplar_frontend_admin_url
  url = base_url + new_agency_user_session_path
  visit url
end

Then(/^the agency user login page is shown$/) do
  current_path.should match /agency_users\/sign_in/i
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
  get_database_object_for_user_type(user_type).access_locked?.should be_false
end

Given(/^an External User exists but has not confirmed their account$/) do
  get_database_object_for_user_type('External User').confirmed?.should be_false
end

When(/^(\d+) consecutive unsuccessful log-in attempts cause the ([\w ]+) account to be locked$/) do |num_login_attempts, user_type|
  emailAddress = get_factorygirl_user_for_user_type(user_type).email
  new_session_page = get_new_session_path_for_user_type(user_type)
  for n in (1..(num_login_attempts.to_i()))
    visit new_session_page
    fill_in 'Email', with: emailAddress
    fill_in 'Password', with: 'this_is_the_wrong_password'
    click_button 'sign_in_button'
    page.should have_content 'Invalid email or password'
  end
  get_database_object_for_user_type(user_type).access_locked?.should be_true
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
  click_button 'submitButton'
end

When (/^completes the request using a guessed email address$/) do
  fill_in 'Email', with: 'a_guessed_address@example.com'
  click_button 'submitButton'
end

Then(/^they should be redirected to the login page, but not told if the email address they supplied was known or unknown$/) do
  current_path.should match /sign_in/i
  # Note: we can't really guarantee that the page doesn't contain ANY clues about whether or not the
  # email address exists; we limit our test to looking for the key phrase "*IF* your account exists..."
  find_by_id('notice_explanation').should have_content /if your (email address|account) exists/i
  find_field('Email').value.should be_blank
end

Then(/^the ([\w ]+) should receive an email containing a link which allows the password to be reset$/) do |user_type|
  open_email get_factorygirl_user_for_user_type(user_type).email
  current_email.subject.should == 'Reset password instructions'
  current_email.click_link 'password_reset_link'
  page.has_content? 'user_password_confirmation'
end

Then(/^the ([\w ]+) should receive an email containing a link which unlocks the account$/) do |user_type|
  open_email get_factorygirl_user_for_user_type(user_type).email
  current_email.subject.should == 'Unlock Instructions'
  current_email.click_link 'unlock_link'
  current_path.should match /sign_in/i
end

Then(/^the ([\w ]+) account 'locked' status should be (\w+)$/) do |user_type, expected_locked_status|
  if expected_locked_status == 'unlocked'
    get_database_object_for_user_type(user_type).access_locked?.should be_false
  elsif expected_locked_status == 'locked'
    get_database_object_for_user_type(user_type).access_locked?.should be_true
  else
    throw 'Unknown value specified for expected_locked_status'
  end
end

Then(/^the External User should receive an email allowing them to confirm their account$/) do
  open_email my_user.email
  current_email.subject.should == 'Verify your email address'
  current_email.click_link 'confirmation_link'
  get_database_object_for_user_type('External User').confirmed?.should be_true
end
