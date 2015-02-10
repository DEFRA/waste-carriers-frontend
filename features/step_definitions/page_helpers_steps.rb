# These steps relate to a quarantined feature and should not be reused. Please
# see the comment in page_helpers.feature for an explanation

When(/^I visit the start page$/) do
  go_to_start_page
end

When(/^select the start page's 'new' option$/) do
  start_page_select_new
end

When(/^select the start page's 'renew' option$/) do
  start_page_select_renew
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

When(/^I am shown the 'start' page$/) do
  page.should start_page?
end

When(/^I am shown the 'type of business' page$/) do
  business_type_page?
end

When(/^I am shown the 'other businesses' page$/) do
  other_businesses_page?
end

When(/^I am shown the 'construction' page$/) do
  construction_demolition_page?
end

When(/^I am shown the 'carrier, broker and dealer' page$/) do
  registration_type_page?
end

When(/^I am shown the 'only deal with' page$/) do
  only_deal_with_page?
end

When(/^I enter a recognised IR number$/) do
  existing_registration_page_complete_form
end
