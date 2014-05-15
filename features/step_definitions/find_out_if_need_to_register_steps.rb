Given(/^I have found out that I need to register in the lower tier$/) do
  visit find_path
  choose 'Sole trader'
  click_on 'Next'
  choose 'registration_otherBusinesses_no'
  click_on 'Next'
  choose 'registration_constructionWaste_no'
  click_on 'Next'
end