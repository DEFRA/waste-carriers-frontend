When(/^I open the registrations export page directly$/) do
  open_registrations_export_page_directly
end

When(/^I open the payments export page directly$/) do
  open_payments_export_page_directly
end

Then(/^I see the agency user login page$/) do
  find_by_id('agency_user_email')
end

Then(/^I can see the registrations export page/) do
  check_registrations_export_page_visible
end

Then(/^I can see the payments export page/) do
  check_payments_export_page_visible
end
