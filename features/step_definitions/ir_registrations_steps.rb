Given(/^I am renewing an IR registration$/) do
  repopulate_database_with_IR_data
  visit start_path
  choose 'registration_newOrRenew_renew'
  click_button 'continue'
  fill_in 'registration_originalRegistrationNumber', with: 'CB/AN9999YY/R002'
  click_button 'continue'
end

Given(/^I Click Continue$/) do
  click_button 'continue'
end

Given(/^I have chosen to renew my registration from IR$/) do
  repopulate_database_with_IR_data
  go_to_start_page
  start_page_select_renew(true)
end

When(/^I enter my IR registration number for a Sole trader and pay by credit card$/) do
  existing_registration_page_enter_sole_trader_registration_number
  business_type_page_submit
  other_businesses_page_select_yes
  service_provided_page_select_yes
  only_deal_with_page_select_no
  registration_type_page_submit
  business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit
  contact_details_page_enter_contact_details_and_submit
  postal_address_page_complete_form
  enter_key_people_details_and_submit
  relevant_convictions_page_select_no
end

When('I enter my expired IR registration number for a Sole trader and pay by credit card') do
  existing_registration_page_enter_sole_trader_expired_registration_number
  business_type_page_submit
  other_businesses_page_select_yes
  service_provided_page_select_yes
  only_deal_with_page_select_no
  registration_type_page_submit
  business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit
  contact_details_page_enter_contact_details_and_submit
  postal_address_page_complete_form
  enter_key_people_details_and_submit
  relevant_convictions_page_select_no
end

When(/^I enter my IR registration number for a public body and change my business name$/) do
  existing_registration_page_enter_public_body_registration_number
  business_type_page_submit
  other_businesses_page_select_yes
  service_provided_page_select_yes
  only_deal_with_page_select_no
  registration_type_page_submit
  business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit(companyName:'New Public Body')
  contact_details_page_enter_contact_details_and_submit
  postal_address_page_complete_form
  enter_key_people_details_and_submit
  relevant_convictions_page_select_no
end

When(/^I enter my IR registration number for a partnership and pay by bank transfer$/) do
  existing_registration_page_enter_partnership_registration_number
  business_type_page_submit
  other_businesses_page_select_yes
  service_provided_page_select_yes
  only_deal_with_page_select_no
  registration_type_page_submit
  business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit
  contact_details_page_enter_contact_details_and_submit
  postal_address_page_complete_form
  enter_multiple_key_people_details_and_submit
  relevant_convictions_page_select_no
end

When(/^I enter my IR registration number for a Sole trader with convictions and pay by bank transfer$/) do
  existing_registration_page_enter_sole_trader_registration_number
  business_type_page_submit
  other_businesses_page_select_yes
  service_provided_page_select_yes
  only_deal_with_page_select_no
  registration_type_page_submit
  business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit
  contact_details_page_enter_contact_details_and_submit
  postal_address_page_complete_form
  enter_key_people_details_and_submit
  relevant_convictions_page_select_yes
  relevant_people_page_enter_multiple_convicted_people_and_submit
end

When(/^I am registering an IR registration for a Sole trader and pay by credit card$/) do
  existing_registration_page_enter_sole_trader_registration_number
  business_type_page_submit
  other_businesses_page_select_yes
  service_provided_page_select_yes
  only_deal_with_page_select_no
  registration_type_page_submit
  business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit
  contact_details_page_enter_ad_contact_details_and_submit
  postal_address_page_complete_form
  enter_key_people_details_and_submit
  relevant_convictions_page_select_no
end

When(/^I am registering an IR registration for a Public body and pay by credit card$/) do
  existing_registration_page_enter_public_body_registration_number
  business_type_page_submit
  other_businesses_page_select_yes
  service_provided_page_select_yes
  only_deal_with_page_select_no
  registration_type_page_submit
  business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit
  contact_details_page_enter_ad_contact_details_and_submit
  postal_address_page_complete_form
  enter_key_people_details_and_submit
  relevant_convictions_page_select_yes
  relevant_people_page_enter_multiple_convicted_people_and_submit
end

Given(/^I am registering an IR registration for a Partnership and pay by bank transfer$/) do
  existing_registration_page_enter_partnership_registration_number
  business_type_page_submit
  other_businesses_page_select_yes
  service_provided_page_select_yes
  only_deal_with_page_select_no
  registration_type_page_submit
  business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit
  contact_details_page_enter_ad_contact_details_and_submit
  postal_address_page_complete_form
  enter_multiple_key_people_details_and_submit
  relevant_convictions_page_select_no
end

Given(/^I enter multiple key people$/) do
  enter_multiple_key_people_details_and_submit
end

When(/^I enter my IR registration number for a partnership and pay by credit card$/) do
  existing_registration_page_enter_partnership_registration_number
  business_type_page_submit
  other_businesses_page_select_yes
  service_provided_page_select_yes
  only_deal_with_page_select_no
  registration_type_page_submit
  business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit
  contact_details_page_enter_contact_details_and_submit
  postal_address_page_complete_form
  enter_multiple_key_people_details_and_submit
  relevant_convictions_page_select_no
end

Given(/^I am registering an IR registration for a limited company with convictions and pay by bank transfer$/) do
  existing_registration_page_enter_limited_company_registration_number
  business_type_page_submit
  other_businesses_page_select_yes
  service_provided_page_select_yes
  only_deal_with_page_select_no
  registration_type_page_submit
  business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit
  contact_details_page_enter_ad_contact_details_and_submit
  postal_address_page_complete_form
  enter_key_people_details_and_submit
  relevant_convictions_page_select_yes
  relevant_people_page_enter_multiple_convicted_people_and_submit
end

When(/^I enter my IR registration number for a limited company with convictions and pay by credit card$/) do
  existing_registration_page_enter_limited_company_registration_number
  business_type_page_submit
  other_businesses_page_select_yes
  service_provided_page_select_yes
  only_deal_with_page_select_no
  registration_type_page_submit
  business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit
  contact_details_page_enter_contact_details_and_submit
  postal_address_page_complete_form
  enter_key_people_details_and_submit
  relevant_convictions_page_select_yes
  relevant_people_page_enter_multiple_convicted_people_and_submit
end

Given(/^I am registering an IR registration for a limited company changing waste carrier type and pay by credit card$/) do
  existing_registration_page_enter_limited_company_registration_number
  business_type_page_submit
  other_businesses_page_select_yes
  service_provided_page_select_yes
  only_deal_with_page_select_no
  registration_type_page_select_carrier_dealer
  business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit
  contact_details_page_enter_ad_contact_details_and_submit
  postal_address_page_complete_form
  enter_key_people_details_and_submit
  relevant_convictions_page_select_no
end
Given(/^I am registering an IR registration for a limited company changing CD to BD and pay by credit card$/) do
  existing_registration_page_enter_limited_company_registration_number
  business_type_page_submit
  other_businesses_page_select_yes
  service_provided_page_select_yes
  only_deal_with_page_select_no
  registration_type_page_select_broker_dealer
  business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit
  contact_details_page_enter_ad_contact_details_and_submit
  postal_address_page_complete_form
  enter_key_people_details_and_submit
  relevant_convictions_page_select_no
end

Given(/^I am registering an IR registration for a Sole trader changing waste carrier type with convictions and pay by bank transfer$/) do
  existing_registration_page_enter_sole_trader_registration_number
  business_type_page_submit
  other_businesses_page_select_yes
  service_provided_page_select_yes
  only_deal_with_page_select_no
  registration_type_page_select_carrier_broker_dealer
  registration_type_page_submit
  business_details_page_enter_business_or_organisation_details_postcode_lookup_and_submit
  contact_details_page_enter_ad_contact_details_and_submit
  postal_address_page_complete_form
  enter_key_people_details_and_submit
  relevant_convictions_page_select_yes
  relevant_people_page_enter_multiple_convicted_people_and_submit
end

Then(/^a renewal fee will be charged$/) do
  confirmation_page_registration_check_for_renewal_text
  confirmation_page_agree_to_declaration_and_submit
  order_page_enter_copy_cards(no_of_cards: 0)
  order_page_check_total_charge(amount: '105.00')
end

Then(/^I will be charged a renewal fee$/) do
  confirmation_page_registration_check_for_renewal_text
  confirmation_page_agree_to_declaration_and_submit
  enter_email_details_and_submit
  # order_page_enter_copy_cards(no_of_cards:0)
  order_page_check_total_charge(amount: '105.00')
end

Then(/^I will be charged the full fee$/) do
  confirmation_page_registration_check_for_expired_renewal_text
  confirmation_page_agree_to_declaration_and_submit
  enter_email_details_and_submit
  # order_page_enter_copy_cards(no_of_cards:0)
  order_page_check_total_charge(amount: '154.00')
end

Then(/^there will be a renewal and edit amount charged$/) do
  confirmation_page_registration_check_for_renewal_text
  confirmation_page_agree_to_declaration_and_submit
  order_page_enter_copy_cards(no_of_cards: 0)
  # renewal fee is 105 plus 40 edit charge
  order_page_check_total_charge(amount: '145.00')
end

Then(/^the correct renewal charge should be shown$/) do
  finish_assisted_page_check_charge_amount(amount: '105.00')
end

Then(/^my correct renewal charge should be shown$/) do
  confirmed_page_check_charge_amount(amount: '105.00')
end

Then(/^the correct renewal and edit charge should be shown$/) do
  finish_assisted_page_check_charge_amount(amount: '145.00')
end

Then(/^the callers registration should be complete when payment is successful$/) do
  order_page_submit
  secure_payment_page_pay_by_visa
  secure_payment_details_page_enter_visa_details_and_submit
  secure_test_simulator_page_continue
  finish_assisted_page_check_registration_complete_text
end

Then(/^my registration should be pending convictions checks when payment is successful$/) do
  order_page_submit
  secure_payment_page_pay_by_maestro
  secure_payment_details_page_enter_visa_details_and_submit
  secure_test_simulator_page_continue
  confirmed_page_check_pending_convictions_text
end

Then(/^the callers registration should be pending convictions checks when payment is successful$/) do
  order_page_submit
  secure_payment_page_pay_by_maestro
  secure_payment_details_page_enter_visa_details_and_submit
  secure_test_simulator_page_continue
  finish_assisted_page_check_pending_convictions_text
end

Given(/^I have completed smart answers given my existing IR data$/) do
  # Prepopulated business type
  # assume pre pop business type
  # choose 'registration_businessType_soletrader'
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
  # assumes original value was soletrader, thus Public Body is a change from
  # original
  choose 'registration_businessType_publicbody'
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
  expect(page).to have_text 'Registration complete'
end

Then(/^the callers registration should be complete$/) do
  finish_assisted_page_check_registration_complete_text
end

Then(/^registration should be pending convictions checks$/) do
  expect(page).to have_selector(:id, 'ut_pending_convictions_check')
end

Then(/^the callers registration should be pending convictions checks$/) do
  expect(page).to have_text 'The applicant declared relevant people with '\
                            'convictions'
end

Then(/^registration should be pending payment$/) do
  expect(page).to have_selector(:id, 'ut_bank_transfer')
end

Then(/^the callers registration should be pending payment$/) do
  order_page_pay_by_bank_transfer_and_submit(0)
  finish_assisted_page_check_pending_payment_text
end

Then(/^my registration should be pending payment$/) do
  order_page_pay_ir_by_bank_transfer_and_submit(0)
  confirmed_page_check_pending_payment_text
end

Given(/^I have signed in as an Environment Agency user$/) do
  sign_in_page_sign_in_as_environment_agency_user_and_submit
end

Given(/^have chosen to renew a customers existing licence$/) do
  repopulate_database_with_IR_data
  registrations_page_select_new_registration
  start_page_select_renew
end

When('I only change business details') do
  business_type_page_submit
  other_businesses_page_select_no
  construction_demolition_page_select_yes
  registration_type_page_submit
  business_details_page_enter_ltd_business_details_postcode_lookup_and_submit(
    companyNo: '10926928',
    postcode: 'BS1 5AH',
    address: 'HARMSEN GROUP, TRIODOS BANK, DEANERY ROAD, BRISTOL, BS1 5AH')
  contact_details_page_enter_ad_contact_details_and_submit
  postal_address_page_complete_form
  enter_key_people_details_and_submit
  relevant_convictions_page_select_no
  confirmation_page_agree_to_declaration_and_submit
end

When('I Change the Company Number') do
  business_type_page_submit
  other_businesses_page_select_no
  construction_demolition_page_select_yes
  registration_type_page_submit
  business_details_page_enter_ltd_business_details_postcode_lookup_and_submit(
    companyNo: '10926928',
    postcode: 'BS1 5AH',
    address: 'HARMSEN GROUP, TRIODOS BANK, DEANERY ROAD, BRISTOL, BS1 5AH')
  contact_details_page_enter_ad_contact_details_and_submit
  postal_address_page_complete_form
  enter_key_people_details_and_submit
  relevant_convictions_page_select_no
  confirmation_page_agree_to_declaration_and_submit
end

When(/^I make no other changes to my registration details$/) do
  # noop (step exists for readability of the feature only)
end

When(/^I only change business name$/) do
  business_type_page_submit
  other_businesses_page_select_no
  construction_demolition_page_select_yes
  registration_type_page_submit
  business_details_page_enter_ltd_business_details_postcode_lookup_and_submit(
    companyNo: '10926928',
    companyName: 'New company name')
  contact_details_page_enter_ad_contact_details_and_submit
  postal_address_page_complete_form
  enter_key_people_details_and_submit
  relevant_convictions_page_select_no
  confirmation_page_agree_to_declaration_and_submit
end

When(/^I change business details$/) do
  fill_in 'registration_companyName', with: 'Company Name Change'
  fill_in 'sPostcode', with: 'HP10 9BX'
  click_button 'find_address'
  select '33, FENNELS WAY, FLACKWELL HEATH, HIGH WYCOMBE, HP10 9BX'
  click_button 'continue'
end

When(/^I don't change business details$/) do
  click_button 'continue'
end

Given(/^I don't change waste carrier type$/) do
  click_button 'continue'
end
Given(/^I don't change contact details$/) do
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

Then(/^I should be shown the total cost is the charge amount and renewal amount "(.*?)"$/) do |fee_amount|
  order_page_confirm_registration_fee(fee_amount)
end

Given(/^I change business type to Sole Trader$/) do
  choose 'registration_businessType_soletrader'
  click_button 'continue'
end

Given(/^I change business type to ltd company$/) do
  choose 'registration_businessType_limitedcompany'
  click_button 'continue'
end

Given(/^I change business type to partnership$/) do
  choose 'registration_businessType_partnership'
  click_button 'continue'
end

Then(/^I should be told that I have to start a new registration$/) do
  expect(page).to have_text 'new upper tier registration will be made and '\
                            'will require a payment of £154.00'
end

Given(/^have chosen to renew an existing licence$/) do
  repopulate_database_with_IR_data
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

Then(/^I expect the Carrier Type to be: "(.*?)"$/) do |registration_type|
  field = find(:radio_button, 'registration[registrationType]', checked: true).value
  expect(field).to eq(registration_type)
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
  registration_total_fee = page.find(
    :xpath,
    ".//input[@id='registration_total_fee']"
  ).value
  expect(registration_total_fee).to eq(amount)
end

Then(/^have the option to pay by Credit or Debit card or by bank transfer$/) do
  expect(page).to have_button 'worldpay_button'
  expect(page).to have_button 'offline_pay_button'
end

Given(/^I am renewing a valid IR registration for sole trader$/) do
  fill_in 'registration_originalRegistrationNumber', with: 'CB/AN9999YY/R002'
  click_button 'continue'
end

When(/^I change waste carrier type from CD to CBD$/) do
  choose 'registration_registrationType_carrier_broker_dealer'
  click_button 'continue'
end

When('I Enter my details') do
  fill_in 'key_person_first_name', with: 'Joe'
  fill_in 'key_person_last_name', with: 'Bloggs'
  fill_in 'key_person_dob_day', with: '01'
  fill_in 'key_person_dob_month', with: '02'
  fill_in 'key_person_dob_year', with: '1980'
  click_button 'continue'
end

When('I Enter my details for two partners') do
  fill_in 'key_person_first_name', with: 'Joe'
  fill_in 'key_person_last_name', with: 'Bloggs'
  fill_in 'key_person_dob_day', with: '01'
  fill_in 'key_person_dob_month', with: '02'
  fill_in 'key_person_dob_year', with: '1980'
  click_button 'add_btn'

  fill_in 'key_person_first_name', with: 'Joanne'
  fill_in 'key_person_last_name', with: 'Bloggs'
  fill_in 'key_person_dob_day', with: '02'
  fill_in 'key_person_dob_month', with: '03'
  fill_in 'key_person_dob_year', with: '1980'
  click_button 'continue'
end

Given(/^I am renewing a valid CBD IR registration for Partnership$/) do
  fill_in 'registration_originalRegistrationNumber', with: 'CB/AN9999ZZ/R002'
  click_button 'continue'
end

When(/^I change waste carrier type from CBD to BD$/) do
  choose 'registration_registrationType_broker_dealer'
  click_button 'continue'
end

Given(/^I am renewing a valid CD IR registration for Public Body$/) do
  fill_in 'registration_originalRegistrationNumber', with: 'CB/VM9999WW/A001'
  click_button 'continue'
end

Given(/^I am renewing a valid BD IR registration for limited company$/) do
  fill_in 'registration_originalRegistrationNumber', with: 'CB/AE9999XX/A001'
  click_button 'continue'
end

When(/^I change waste carrier type from CD to BD$/) do
  choose 'registration_registrationType_broker_dealer'
  click_button 'continue'
end

Given(/^I am renewing a valid CBD IR registration for limited company$/) do
  existing_registration_page_enter_limited_company_registration_number
end

Given(/^I Search for the Client Details with a IR Registration Number$/) do
  existing_registration_page_enter_IR_renewl_registration_number
end

When(/^I change waste carrier type from BD to CD$/) do
  choose 'registration_registrationType_carrier_dealer'
  click_button 'continue'
end

When(/^I change waste carrier type to CD$/) do
  choose 'registration_registrationType_carrier_dealer'
  click_button 'continue'
end

Given(/^I am renewing a valid BD IR registration for Partnership$/) do
  fill_in 'registration_originalRegistrationNumber', with: 'CB/AN9999ZZ/R003'
  click_button 'continue'
end

When(/^I change waste carrier type from BD to CBD$/) do
  choose 'registration_registrationType_carrier_broker_dealer'
  click_button 'continue'
end

Then(/^registration should be complete when payment is successful$/) do
  order_page_pay_by_credit_card
  secure_payment_page_pay_by_visa
  secure_payment_details_page_enter_visa_details_and_submit
  secure_test_simulator_page_continue
  confirmed_page_check_text_registration_complete
end
