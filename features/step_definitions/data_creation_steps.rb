Given(/^a "(.*?)" lower tier registration$/) do |type|
  registration = create_complete_lower_tier_reg(type)
  expect(registration['metaData']['status']).to eq("ACTIVE")
end

Given(/^a "(.*?)" upper tier registration paid for by "(.*?)" with (\d+) copy cards$/) do |type, method, copy_cards|
  registration = create_complete_upper_tier_reg(type, method, copy_cards)
  @raw_id = registration['id']
  @irCarrierType = registration['registrationType']
  expect(registration['metaData']['status']).to eq("ACTIVE")
end

Given(/^a pending "(.*?)" upper tier registration paid for by "(.*?)" with (\d+) copy cards$/) do |type, method, copy_cards|
  registration = create_complete_upper_tier_reg(type, method, copy_cards)
  expect(registration['metaData']['status']).to eq("PENDING")
end
