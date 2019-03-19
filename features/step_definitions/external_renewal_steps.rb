Then(/^I remember the registration id$/) do
  # Find the registration ID and saves it as a variable for use in a later test
  @stored_value = find_by_id('registrationNumber').text.to_s
end
