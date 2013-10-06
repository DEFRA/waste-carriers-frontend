#Registration step definitions

Given(/^I am on the Start page$/) do
  visit '/registrations/start'
end

Given(/^I click on "(.*?)"$/) do |name|
  click_on(name)
end

Then(/^I should see "(.*?)"$/) do |some_text|
  assert(page.has_content?(some_text))
end

Then(/^I register as a"(.*?)"$/) do |field_value|
  page.select(field_value, :from => 'registration_registerAs')
end

Then(/^I select business or organisation type "(.*?)"$/) do |field_value|
    page.select(field_value, :from => 'registration_organisationType')

end

Then(/^I fill in "(.*?)" with "(.*?)"$/) do |field_name, field_value|
  fill_in(field_name, :with => field_value)
end

Then(/^I click "(.*?)"$/) do |name|
	#TODO - Select the checkbox
  #check(name)
end

Then(/^I fill in valid contact details$/) do
  assert(page.has_content?('Address and contact details'))
  find_field('registration_houseNumber')
  fill_in('registration_houseNumber', :with => '12a')
  fill_in('registration_postcode', :with => 'SW1 23A')
  page.select('Mr', :from => 'registration_title')
  fill_in('registration_firstName', :with => 'Joe')  
  fill_in('registration_lastName', :with => 'Bloggs')  
  fill_in('registration_phoneNumber', :with => '0123 456')  
  fill_in('registration_emailAddress', :with => 'joe@bloggs.com')  
end

Then(/^I select the declaration checkbox$/) do
  click_on('declaration')
end

Then(/^I should see the Confirmation page$/) do
  #TODO verify page contents
end
