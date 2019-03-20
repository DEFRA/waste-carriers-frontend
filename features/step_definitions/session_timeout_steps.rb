When(/^I do nothing for more than (\d+) minutes$/) do |m|
  Timecop.travel(m.to_i.minutes.from_now + 1.minute)
end

When(/^I want to continue with my administration tasks$/) do
  visit new_admin_session_path
end

Then(/^I am informed that my session has expired$/) do
  expect(page).to have_text 'Your session has expired'
end

Given('I have started a new registration and gone as far as the Waste From Other Businesses step') do
  go_to_start_page
  start_page_select_new
  location_page?
  location_page_select_england
  business_type_page?
  business_type_page_select_sole_trader
  other_businesses_page?
end

When('I can still continue past the Waste From Other Businesses step') do
  other_businesses_page?
  other_businesses_page_select_yes
  service_provided_page?
end

Given(/^I keep working on my registration for more than (\d+) hours$/) do |number_of_hours|
  # Note: We could keep accessing the current page to avoid session inactivity timeouts - but this should not be necessary for WCs
  Timecop.travel(number_of_hours.to_i.hours.from_now + 1.minute)
end
