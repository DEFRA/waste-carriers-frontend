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
  page.has_text? 'Registration complete'
end

Then(/^the callers registration should be complete$/) do
  page.has_text? 'Registration complete'
  page.has_text? 'has been registered as an upper tier waste carrier'

  # validate the access code is present and of the correct length
  access_code = page.find_by_id 'accessCode'
  access_code.text.length.should == 6
end

Then(/^registration should be pending convictions checks$/) do
  page.find_by_id "ut_pending_convictions_check"
end

Then(/^the callers registration should be pending convictions checks$/) do
  page.has_text? 'The applicant declared relevant people with convictions'

  # validate the access code is present and of the correct length
  access_code = page.find_by_id 'accessCode'
  access_code.text.length.should == 6
end

Then(/^registration should be pending payment$/) do
  page.find_by_id "ut_bank_transfer"
end

Then(/^the callers registration should be pending payment$/) do
  page.has_text? 'Please remind the applicant to arrange a bank transfer'

  # validate the access code is present and of the correct length
  access_code = page.find_by_id 'accessCode'
  access_code.text.length.should == 6
end
