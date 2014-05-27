Given(/^I am logged in as an NCCC agency user$/) do
  visit new_agency_user_session_path
  page.should have_content 'Sign in'
  page.should have_content 'NCCC agency login'
  fill_in 'Email', with: my_agency_user.email
  fill_in 'Password', with: my_agency_user.password
  click_button 'Sign in'
  page.should have_content "Signed in as agency user #{my_agency_user.email}"
end

Given(/^I start a new registration$/) do
  visit registrations_path
  click_button 'New registration'
end

Then(/^I should see the Business or Organisation Details page$/) do
  page.should have_content 'What type of business or organisation are you?'
end

Then(/^I fill in valid contact details without email$/) do
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
  # specifically "the registration confirmation email should not be sent *to the agency user" (for whom this is the only email address provided)
  open_email my_agency_user.email
  current_email.should be_nil
end

Then(/^when I access the print page$/) do
  click_button 'View certificate'
end

Then(/^the print page contains the six-digit access code for the user$/) do
  page.should have_content 'access code'
  access_code = page.find_by_id 'accessCode'
  access_code.text.length.should == 6
end

When(/^I create a lower tier registration on behalf of a caller$/) do
  click_on 'New registration'

  choose 'registration_businessType_charity'
  click_on 'Next'

  fill_in 'Business or organisation trading name', with: 'Grades'
  fill_in 'sPostcode', with: 'BS1 2EP'
  click_on 'Find UK address'

  select 'Grades Gents Hairdressers, 44 Broad Street, City Centre, Bristol BS1 2EP'
  click_on 'Next'

  fill_in 'First name', with: 'Joe'
  fill_in 'Last name', with: 'Bloggs'
  fill_in 'Job title', with: 'Chief Barber'
  fill_in 'Phone number', with: '0117 926 8332'
  fill_in 'Email address', with: my_email_address
  click_on 'Next'

  check 'registration_declaration'
  click_on 'Next'

  click_on 'Next'
end

When(/^I create an upper tier registration on behalf of a caller$/) do
  click_on 'New registration'

  choose 'registration_businessType_soletrader'
  click_on 'Next'

  choose 'registration_otherBusinesses_yes'
  click_on 'Next'

  choose 'registration_isMainService_yes'
  click_on 'Next'

  choose 'registration_onlyAMF_no'

  click_on 'Next'

  choose ''

  save_and_open_page
  pending

  choose 'registration_businessType_charity'
  click_on 'Next'

  fill_in 'Business or organisation trading name', with: 'Grades'
  fill_in 'sPostcode', with: 'BS1 2EP'
  click_on 'Find UK address'

  select 'Grades Gents Hairdressers, 44 Broad Street, City Centre, Bristol BS1 2EP'
  click_on 'Next'

  fill_in 'First name', with: 'Joe'
  fill_in 'Last name', with: 'Bloggs'
  fill_in 'Job title', with: 'Chief Barber'
  fill_in 'Phone number', with: '0117 926 8332'
  fill_in 'Email address', with: my_email_address
  click_on 'Next'

  check 'registration_declaration'
  click_on 'Next'

  click_on 'Next'
end