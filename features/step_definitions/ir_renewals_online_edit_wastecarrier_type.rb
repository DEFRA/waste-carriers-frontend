Given(/^have chosen to renew an existing licence$/) do
   RestClient.post Rails.configuration.waste_exemplar_services_admin_url + '/tasks/ir-repopulate', :content_type => :json, :accept => :json
   visit start_path
   start_page_select_renew
end



Given(/^I don't change business type$/) do
  click_button 'continue'

end

Given(/^the smart answers keep me in Upper tier$/) do
   choose 'registration_otherBusinesses_no'
  click_button 'continue'
  choose 'registration_constructionWaste_yes'
  click_button 'continue'


end

When(/^I change waste carrier type from CBD to CD$/) do
  choose 'registration_registrationType_carrier_dealer'
  click_button 'continue'
end

When(/^I Enter business details$/) do
  fill_in 'sPostcode', with: 'HP10 9BX'
  click_button 'find_address'
  select '33, FENNELS WAY, FLACKWELL HEATH, HIGH WYCOMBE, HP10 9BX'
  click_button 'continue'
end

When(/^I Enter my contact details$/) do
    fill_in 'registration_firstName', with: 'Joe'
    fill_in 'registration_lastName', with: 'Bloggs'
    fill_in 'registration_phoneNumber', with: '0117 926 8332'
    fill_in 'registration_contactEmail', with: my_email_address
    click_button 'continue'
end

When(/^I Enter key people details$/) do
    fill_in 'key_person_first_name', with: 'Joe'
    fill_in 'key_person_last_name', with: 'Bloggs'
    fill_in 'key_person_dob_day', with: '01'
    fill_in 'key_person_dob_month', with: '02'
    fill_in 'key_person_dob_year', with: '1980'
    click_button 'add_btn'
    click_button 'continue'
end

When(/^I have no relevant convictions$/) do
  choose 'registration_declaredConvictions_no'
  click_button 'continue'
end

When(/^I confirm my details$/) do
  check 'registration_declaration'
  click_button 'confirm'

   fill_in 'registration_accountEmail', with: my_email_address
  fill_in 'registration_accountEmail_confirmation', with: my_email_address
  fill_in 'registration_password', with: my_password
  fill_in 'registration_password_confirmation', with: my_password
  click_button 'continue'
end


Then(/^I should be shown the total cost "(.*?)"$/) do |amount|
  registration_total_fee = page.find(:xpath, ".//input[@id='registration_total_fee']").value
  assert_equal amount, registration_total_fee
end

Then(/^have the option to pay by Credit or Debit card or by bank transfer$/) do
  page.should have_button 'worldpay_button'
  page.should have_button 'offline_pay_button'
end

Given(/^I am renewing a valid IR registration for sole trader$/) do
  choose 'registration_newOrRenew_renew'
  click_button 'continue'
  fill_in 'registration_originalRegistrationNumber', with: 'CB/AN8888YY/R002'
  click_button 'continue'
end

When(/^I change waste carrier type from CD to CBD$/) do
 choose 'registration_registrationType_carrier_broker_dealer'
 click_button 'continue'
end

When(/^I Enter my details$/) do
     fill_in 'key_person_first_name', with: 'Joe'
    fill_in 'key_person_last_name', with: 'Bloggs'
    fill_in 'key_person_dob_day', with: '01'
    fill_in 'key_person_dob_month', with: '02'
    fill_in 'key_person_dob_year', with: '1980'
    click_button 'continue'
end

Given(/^I am renewing a valid CBD IR registration for Partnership$/) do
    choose 'registration_newOrRenew_renew'
  click_button 'continue'
  fill_in 'registration_originalRegistrationNumber', with: 'CB/AN8888ZZ/R002'
  click_button 'continue'
end

When(/^I change waste carrier type from CBD to BD$/) do
  choose 'registration_registrationType_broker_dealer'
  click_button 'continue'
end

Given(/^I am renewing a valid CD IR registration for Public Body$/) do
      choose 'registration_newOrRenew_renew'
  click_button 'continue'
  fill_in 'registration_originalRegistrationNumber', with: 'CB/VM8888WW/A001'
  click_button 'continue'
end

When(/^I change waste carrier type from CD to BD$/) do
  choose 'registration_registrationType_broker_dealer'
  click_button 'continue'
end

Given(/^I am renewing a valid CBD IR registration for limited company$/) do
   existing_registration_page_enter_limited_company_registration_number
end

When(/^I change waste carrier type from BD to CD$/) do
   choose 'registration_registrationType_carrier_dealer'
    click_button 'continue'
end


Given(/^I am renewing a valid BD IR registration for Partnership$/) do
     choose 'registration_newOrRenew_renew'
  click_button 'continue'
  fill_in 'registration_originalRegistrationNumber', with: 'CB/AN8888ZZ/R003'
  click_button 'continue'
end

When(/^I change waste carrier type from BD to CBD$/) do
   choose 'registration_registrationType_carrier_broker_dealer'
 click_button 'continue'
end
