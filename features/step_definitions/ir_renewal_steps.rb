Given(/^I am renewing an IR registration$/) do

  # Manually force a repopulation of IR data in database
  RestClient.post Rails.configuration.waste_exemplar_services_admin_url + '/tasks/ir-repopulate', :content_type => :json, :accept => :json
  #sleep 1.0			# Wait a period for background task of pre-population to occur

  visit start_path
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

Given(/^I have completed smart answers, but changed my business type$/) do
  # Prepopulated business type
  choose 'registration_businessType_partnership'  # assumes original value was soletrader, thus partnership is a change from original
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

Then(/^the callers registration should be complete$/) do
  page.should have_content 'Registration complete'
  page.should have_content 'has been registered as an upper tier waste carrier'

  # validate the access code is present and of the correct length
  access_code = page.find_by_id 'accessCode'
  access_code.text.length.should == 6
end

Then(/^registration should be pending convictions checks$/) do
  page.should have_content 'Application Received'
  page.should have_content 'We are running background checks on the information you have provided'
end

Then(/^the callers registration should be pending convictions checks$/) do
  page.should have_content 'The applicant declared relevant people with convictions'

  # validate the access code is present and of the correct length
  access_code = page.find_by_id 'accessCode'
  access_code.text.length.should == 6
end

Then(/^registration should be pending payment$/) do
  page.should have_content 'Application received'
  page.should have_content 'Waiting for confirmation of payment'
end

Then(/^the callers registration should be pending payment$/) do
  page.should have_content 'Please remind the applicant to arrange a bank transfer'

  # validate the access code is present and of the correct length
  access_code = page.find_by_id 'accessCode'
  access_code.text.length.should == 6
end
