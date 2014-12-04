Given(/^a "(.*?)" lower tier registration$/) do |type|
  registration = create_complete_lower_tier_reg(type)
  assert_equal "ACTIVE", registration['metaData']['status']
end

Given(/^a "(.*?)" upper tier registration paid for by "(.*?)" with (\d+) copy cards$/) do |type, method, copy_cards|
  registration = create_complete_upper_tier_reg(type, method, copy_cards)
  assert_equal "ACTIVE", registration['metaData']['status']
end
