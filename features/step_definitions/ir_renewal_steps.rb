Given(/^I am renewing an IR registration$/) do
  
  # Manually force a repopulation of IR data in database
  RestClient.post 'http://localhost:9091/tasks/ir-repopulate', :content_type => :json, :accept => :json
  #sleep 1.0			# Wait a period for background task of pre-population to occur
  
  visit newOrRenew_path
  choose 'registration_newOrRenew_renew'
  click_on 'Next'
  fill_in 'registration_originalRegistrationNumber', with: 'CB/AE5892RG/A001'
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