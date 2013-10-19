#Registration step definitions
#Capybara syntax (visit, fill_in, ...) see e.g. https://github.com/jnicklas/capybara

Given(/^I am on the Start page$/) do
  visit '/registrations/start'
end

Given(/^I click on "(.*?)"$/) do |name|
  click_on(name)
end

Then(/^I should see "(.*?)"$/) do |some_text|
  assert(page.has_content?(some_text))
end

Then(/^I select business or organisation type "(.*?)"$/) do |field_value|
    page.select(field_value, :from => 'registration_businessType')

end

Then(/^I fill in "(.*?)" with "(.*?)"$/) do |field_name, field_value|
  fill_in(field_name, :with => field_value)
end

Then(/^I click "(.*?)"$/) do |name|
  click_on name
end

Then(/^I fill in valid contact details$/) do
  find_field('registration_houseNumber')
  #assert(page.has_content?('Address and contact details'))
  fill_in('registration_houseNumber', :with => '12')
  fill_in('registration_postcode', :with => 'SW1 2AB')

  #click_button 'findAddress'
  #page.select('addr1', :from => 'addresses')

  page.select('Mr', :from => 'registration_title')
  fill_in('registration_firstName', :with => 'Joe')  
  fill_in('registration_lastName', :with => 'Bloggs')  
  fill_in('registration_phoneNumber', :with => '0123 456')  
  fill_in('registration_email', :with => 'joe@bloggs.com')  
end


Then(/^I select the declaration checkbox$/) do
  find_field('registration_declaration')
  check('registration_declaration')
end

Then(/^I should see the Confirmation page$/) do
  #TODO verify page contents
end


#Alternate version....


When(/^I provide valid individual trading name details$/) do
  #The registerAs field dropdown has been removed...
  #page.select('Carrier', :from => 'registration_registerAs')
  page.select('An individual', :from => 'registration_businessType')
  fill_in('registration_companyName', :with => 'Joe Bloggs')  
  click_on('Next')
end

When(/^I provide valid contact details$/) do
  find_field('registration_houseNumber')
  #assert(page.has_content?('Address and contact details'))
  fill_in('registration_houseNumber', :with => '12')
  fill_in('registration_postcode', :with => 'SW12 3AB')
  page.select('Mr', :from => 'registration_title')
  fill_in('registration_firstName', :with => 'Joe')  
  fill_in('registration_lastName', :with => 'Bloggs')  
  fill_in('registration_phoneNumber', :with => '0123 456')  
  fill_in('registration_email', :with => 'joe@bloggs.com')  
  click_on('Next')
  assert(page.has_content?('Check details and register'))
end

When(/^I confirm the declaration$/) do
  find_field('registration_declaration')
  check('registration_declaration')
  click_on 'Next'
  click_on 'Register'
end
