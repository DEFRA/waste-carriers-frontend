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

Given(/^I have gone through the upper tier waste carrier process$/) do
  pending
end