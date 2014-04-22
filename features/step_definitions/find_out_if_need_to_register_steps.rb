Given(/^I have found out that I need to register in the lower tier$/) do
  visit find_path
  page.should have_content 'Find out if you need to register and which category applies'
  page.select 'Sole trader', from: 'discover_businessType'
  choose 'discover_otherBusinesses_no'
  choose 'discover_constructionWaste_no'
  click_button 'register_lower_tier'
end