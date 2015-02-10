When(/^I visit the start page$/) do
  go_to_start_page
end

When(/^select the start page's 'new' option$/) do
  start_page_select_new
end

When(/^I select the business type page's 'sole trader' option$/) do
  business_type_page_select_sole_trader
end

When(/^I select the other businesses page's 'no' option$/) do
  other_businesses_page_select_no
end

When(/^I select the other businesses page's 'yes' option$/) do
  other_businesses_page_select_yes
end

When(/^I select the construction page's 'yes' option$/) do
  construction_demolition_page_select_yes
end

When(/^I select the service provided page's 'yes' option$/) do
  service_provided_page_select_yes
end

When(/^I select the only deal with page's 'no' option$/) do
  only_deal_with_page_select_no
end

When(/^I am shown the "(.*?)" page$/) do |name|
  page.should have_content name
end
