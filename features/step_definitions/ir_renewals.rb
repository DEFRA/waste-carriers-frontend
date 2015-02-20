
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
  confirm_registration_and_submit
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
  confirm_registration_and_submit
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
  complete_order_pay_check_total_charge
end