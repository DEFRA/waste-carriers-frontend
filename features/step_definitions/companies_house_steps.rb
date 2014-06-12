Given(/^system user is at the company details page$/) do
	visit find_path
end

And(/^a valid (\d+) is entered$/) do |company_number|
  click_on 'FindCompanyDetails'
end

Then(/^)the companies house system validates that the company is valid$/)
page.should have_content