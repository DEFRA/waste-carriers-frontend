When(/^I visit the start page$/) do
  go_to_start_page
end

When(/^select the start page's "(.*?)" option$/) do |value|
  start_page_select_and_submit value
end

When(/^I select the business type page's "(.*?)" option$/) do |value|
  business_type_page_select_and_submit value
end

When(/^I select the other businesses page's "(.*?)" option$/) do |value|
  other_businesses_page_select_and_submit value
end

When(/^I select the construction page's "(.*?)" option$/) do |value|
  construction_demolition_page_select_and_submit value
end

When(/^I select the service provided page's "(.*?)" option$/) do |value|
  service_provided_page_select_and_submit value
end

When(/^I select the only deal with page's "(.*?)" option$/) do |value|
  only_deal_with_page_select_and_submit value
end

When(/^I am shown the "(.*?)" page$/) do |name|
  page.should have_content name
end
