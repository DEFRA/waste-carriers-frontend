Given(/^I am renewing an IR registration$/) do
  
  # Manually force a repopulation of IR data in database
  RestClient.post Rails.configuration.waste_exemplar_services_admin_url + '/tasks/ir-repopulate', :content_type => :json, :accept => :json
  #sleep 1.0			# Wait a period for background task of pre-population to occur
  
  visit newOrRenew_path
  choose 'registration_newOrRenew_renew'
  click_on 'Next'
  fill_in 'registration_originalRegistrationNumber', with: 'CB/AN9999YY/R002'
  click_on 'Next'
end

Given(/^I have completed smart answers given my existing IR data$/) do
  # Prepopulated business type
  #choose 'registration_businessType_soletrader'  # assume pre pop business type
  click_on 'Next'
  
  # Remaining smart answer questions are not prepopulated
  choose 'registration_otherBusinesses_yes'
  click_on 'Next'
  choose 'registration_isMainService_yes'
  click_on 'Next'
  choose 'registration_onlyAMF_no'
  click_on 'Next'
end

Given(/^my waste carrier status is prepopulated$/) do
  click_on 'Next'
end

Given(/^my company name is prepopulated$/) do
  # perform no action as company name should be prepopulated
end

Then(/^registration should be complete$/) do
  page.should have_content 'Registration complete'
end

Then(/^registration should be pending convictions checks$/) do
  page.should have_content 'Incomplete'
  page.should have_content 'We are running background checks on the information you have provided'
end

Then(/^registration should be pending payment$/) do
  page.should have_content 'Almost there'
  page.should have_content 'Waiting for confirmation of payment'
end
