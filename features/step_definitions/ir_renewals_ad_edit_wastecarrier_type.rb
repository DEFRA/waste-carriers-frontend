Given(/^I have logged in as an Environment Agency user$/) do
   visit new_agency_user_session_path
  page.should have_content 'Sign in'
  page.should have_content 'Environment Agency login'
  fill_in 'Email', with: my_agency_user.email
  fill_in 'Password', with: my_agency_user.password
  click_button 'Sign in'
  page.has_content? 'agency-user-signed-in'
end

Given(/^have chosen to renew a customers existing licence$/) do
	RestClient.post Rails.configuration.waste_exemplar_services_admin_url + '/tasks/ir-repopulate', :content_type => :json, :accept => :json
  click_on 'New registration'
end

When(/^I Enter their contact details$/) do

    fill_in 'registration_firstName', with: 'Joe'
    fill_in 'registration_lastName', with: 'Bloggs'
    fill_in 'registration_phoneNumber', with: '0117 926 8332'
    click_on 'Next'
end

When(/^I confirm their details$/) do
  check 'registration_declaration'
  click_on 'Confirm'
end
