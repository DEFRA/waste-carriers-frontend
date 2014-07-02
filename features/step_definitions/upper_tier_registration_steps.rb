Given(/^I have been funneled into the upper tier path$/) do
  visit find_path

  choose 'registration_businessType_soletrader'
  click_on 'Next'
  choose 'registration_otherBusinesses_yes'
  click_on 'Next'
  choose 'registration_isMainService_yes'
  click_on 'Next'
  choose 'registration_onlyAMF_no'
  click_on 'Next'
end

And(/^I am a carrier dealer$/) do
  choose 'registration_registrationType_carrier_dealer'
  click_on 'Next'
end

And(/^I go past the payment page$/) do
  click_on 'Pay by debit/credit card'
end

Then(/^I am registered as an upper tier waste carrier$/) do
  page.should have_content 'is registered as an upper tier waste carrier'
  open_email my_email_address
  current_email.should have_content 'is registered as an upper tier waste carrier'
end

And(/^I pay by card$/) do
  click_on 'Pay by debit/credit card'

  click_on 'MasterCard'

  fill_in 'Card number', with: '4444333322221111'
  select '12', from: 'cardExp.month'
  select Date.current.year + 2, from: 'cardExp.year'
  fill_in "Cardholder's name", with: 'B Butler'
  fill_in 'Address 1', with: 'Deanery St.'
  fill_in 'Town/City', with: 'Bristol'
  fill_in 'Postcode/ZIP', with: 'BS1 5AH'
  click_on 'op-PMMakePayment'

  sleep 1.5
  click_on 'Continue'

  # click through temporary page but eventually this page should disappear
  # click_on 'Continue'

  save_and_open_page
end