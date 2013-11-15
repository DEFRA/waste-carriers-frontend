## step definitions for 'Find out if I need to register'

Given(/^I have found out that I need to register in the lower tier$/) do
  visit '/registrations/find'
  assert page.has_content?("Find out if you need to register and which category applies")
  page.select('Sole trader', :from => 'discover_businessType')
  choose 'discover_otherBusinesses_no'
  choose 'discover_constructionWaste_no'
  check 'discover_wasteType_other'
  within("//div[@id='lowerText']") do
    click_button "Start now >"
  end
end