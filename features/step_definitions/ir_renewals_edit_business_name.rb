When(/^I change business details$/) do
  fill_in 'registration_companyName', with: 'Company Name Change'
  fill_in 'sPostcode', with: 'HP10 9BX'
  click_on 'Find UK address'
  select '33, FENNELS WAY, FLACKWELL HEATH, HIGH WYCOMBE, HP10 9BX'
  # save_and_open_page
  click_on 'Next'
end

Given(/^I don't change waste carrier type$/) do
  click_on 'Next'
end