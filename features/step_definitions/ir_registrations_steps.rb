Given(/^I am renewing an IR registration$/) do

  # Manually force a repopulation of IR data in database
  RestClient.post Rails.configuration.waste_exemplar_services_admin_url + '/tasks/ir-repopulate', :content_type => :json, :accept => :json
  #sleep 1.0			# Wait a period for background task of pre-population to occur

  visit start_path
  choose 'registration_newOrRenew_renew'
  click_button 'continue'
  fill_in 'registration_originalRegistrationNumber', with: 'CB/AN9999YY/R002'
  click_button 'continue'
end

When(/^I am renewing an IR registration for a Sole trader and pay by credit card$/) do
  existing_registration_page_enter_sole_trader_registration_number
  business_type_page_submit
  other_businesses_page_select_yes
  service_provided_page_select_yes
  only_deal_with_page_select_no
  registration_type_page_submit
  business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit
  contact_details_page_enter_ad_contact_details_and_submit
  enter_key_people_details_and_submit
  relevant_convictions_page_select_no
  confirmation_page_registration_check_for_renewal_text
  confirmation_page_registration_and_submit
  order_page_complete_order_pay_check_total_charge(amount:'154.00')
  order_page_complete_order_pay_by_world_pay_and_submit(0)
  secure_payment_page_pay_by_maestro
  secure_payment_details_page_enter_visa_details_and_submit
  secure_test_simulator_page_continue

end

Given(/^I have completed smart answers given my existing IR data$/) do
  # Prepopulated business type
  #choose 'registration_businessType_soletrader'  # assume pre pop business type
  click_button 'continue'

  # Remaining smart answer questions are not prepopulated
  choose 'registration_otherBusinesses_yes'
  click_button 'continue'
  choose 'registration_isMainService_yes'
  click_button 'continue'
  choose 'registration_onlyAMF_no'
  click_button 'continue'
end

Given(/^I have completed smart answers, but changed my business type$/) do
  # Prepopulated business type
  choose 'registration_businessType_partnership'  # assumes original value was soletrader, thus partnership is a change from original
  click_button 'continue'

  # Remaining smart answer questions are not prepopulated
  choose 'registration_otherBusinesses_yes'
  click_button 'continue'
  choose 'registration_isMainService_yes'
  click_button 'continue'
  choose 'registration_onlyAMF_no'
  click_button 'continue'
end

Given(/^my waste carrier status is prepopulated$/) do
  click_button 'continue'
end

Given(/^my company name is prepopulated$/) do
  # perform no action as company name should be prepopulated
end

Then(/^registration should be complete$/) do
  page.should have_content 'Registration complete'
end

Then(/^the callers registration should be complete$/) do
  finish_assisted_page_check_registration_complete_text
end

Then(/^registration should be pending convictions checks$/) do
  page.find_by_id "ut_pending_convictions_check"
end

Then(/^the callers registration should be pending convictions checks$/) do
  page.should have_content 'The applicant declared relevant people with convictions'

  # validate the access code is present and of the correct length
  access_code = page.find_by_id 'accessCode'
  access_code.text.length.should == 6
end

Then(/^registration should be pending payment$/) do
  page.find_by_id "ut_bank_transfer"
end

Then(/^the callers registration should be pending payment$/) do
  page.should have_content 'Please remind the applicant to arrange a bank transfer'

  # validate the access code is present and of the correct length
  access_code = page.find_by_id 'accessCode'
  access_code.text.length.should == 6
end


Given(/^I have signed in as an Environment Agency user$/) do
  sign_in_page_sign_in_as_environment_agency_user_and_submit
end

Given(/^have chosen to renew a customers existing licence$/) do
  RestClient.post Rails.configuration.waste_exemplar_services_admin_url + '/tasks/ir-repopulate', :content_type => :json, :accept => :json
   registrations_page_select_new_registration
   start_page_select_renew
end

When(/^I only change business details$/) do
  business_type_page_submit
  other_businesses_page_select_no
  construction_demolition_page_select_yes
  registration_type_page_submit
  business_details_page_enter_ltd_business_details_postcode_lookup_and_submit(companyNo: '07713745',postcode: 'BS1 5AH',
  address: 'HARMSEN GROUP, TRIODOS BANK, DEANERY ROAD, BRISTOL, BS1 5AH')
  contact_details_page_enter_ad_contact_details_and_submit
  enter_key_people_details_and_submit
  relevant_convictions_page_select_no
  confirm_registration_page_and_submit
end

When(/^I only change business name$/) do
  business_type_page_submit
  other_businesses_page_select_no
  construction_demolition_page_select_yes
  registration_type_page_submit
  business_details_page_enter_ltd_business_details_postcode_lookup_and_submit(companyNo: '07713745',companyName: 'New company name')
  contact_details_page_enter_ad_contact_details_and_submit
  enter_key_people_details_and_submit
  relevant_convictions_page_select_no
  confirm_registration_and_page_submit
end

When(/^I change business details$/) do
  fill_in 'registration_companyName', with: 'Company Name Change'
  fill_in 'sPostcode', with: 'HP10 9BX'
  click_button 'find_address'
  select '33, FENNELS WAY, FLACKWELL HEATH, HIGH WYCOMBE, HP10 9BX'
  click_button 'continue'
end

Given(/^I don't change waste carrier type$/) do
  click_button 'continue' 
end

When(/^I Enter their contact details$/) do

    fill_in 'registration_firstName', with: 'Joe'
    fill_in 'registration_lastName', with: 'Bloggs'
    fill_in 'registration_phoneNumber', with: '0117 926 8332'
    click_button 'continue'
end

When(/^I confirm their details$/) do
    check 'registration_declaration'
    click_button 'confirm'
end

Then(/^I should be shown the total cost is the charge amount and renewal amount "(.*?)"$/) do |arg1|
  order_page_complete_order_pay_check_total_charge
end

Given(/^I change business type to Sole Trader$/) do
  choose 'registration_businessType_soletrader'
  click_button 'continue'
end

 Then(/^I should be told that I have to start a new registration$/) do
  page.should have_content 'new upper tier registration will be made and will require a payment of £154.00'
end

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
