Given(/^I have registered as a lower tier charity waste carrier$/) do
  visit start_path
  start_page_select_new
  business_type_page_select_charity
  business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit(companyName: 'Find me in the public register')
  contact_details_page_enter_contact_details_and_submit
  confirmation_page_registration_and_submit
  enter_email_details_and_submit
end

Given(/^I have registered as a lower tier local authority waste carrier$/) do
  visit start_path
  start_page_select_new
  business_type_page_select_charity
  business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit(companyName: 'Unconfirmed company')
  contact_details_page_enter_contact_details_and_submit
  confirmation_page_registration_and_submit
  enter_email_details_and_submit
end

Given(/^I have registered as an upper tier sole trader$/) do
    visit start_path
  	start_page_select_new
  	business_type_page_select_sole_trader
  	other_businesses_page_select_no
  	construction_demolition_page_select_yes
  	registration_type_page_select_carrier_dealer
  	business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit(companyName: 'Unpaid company')
  	contact_details_page_enter_contact_details_and_submit
  	enter_key_people_details_and_submit
  	relevant_convictions_page_select_no
  	confirmation_page_registration_and_submit
  	enter_email_details_and_submit
end

Given(/^I have not paid the registration charge$/) do
  order_page_pay_by_bank_transfer
end

Given(/^I have confirmed my email address details$/) do
  do_short_pause_for_email_delivery
  open_email my_email_address
  current_email.click_link 'confirmation_link'
end

Given(/^I have not confirmed my email address details$/) do
# do nothing
end

Then(/^my lower tier charity waste registration details should be found on the public register$/) do
  search_page_search(companyName: 'Find me in the public register')
  search_page_check_search_result_positive
end

Then(/^my lower tier local autority registration details should not be found on the public register$/) do
  search_page_search(companyName: 'Unconfirmed company')
  search_page_check_search_result_negative
end

Then(/^my upper tier sole trader registration details should not be found on the public register$/) do
  search_page_search(companyName: 'Unpaid company')
  search_page_check_search_result_negative
end

