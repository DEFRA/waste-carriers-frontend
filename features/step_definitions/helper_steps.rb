Given /^PENDING/ do
  pending
end

When(/^I wait for (\d+) seconds{0,1} for these actions to be finalised$/) do |delay_in_seconds|
  sleep delay_in_seconds.to_i
end

When(/^the inbox for '([\w@\.]+)' is emptied now as part of this test$/) do |email_address|
  open_email email_address
  clear_emails
  expect(all_emails).to be_empty
end

Then(/^the inbox for '([\w@\.]+)' should be empty$/) do |email_address|
  open_email email_address
  msg = ''
  if all_emails.count > 0
    msg = ["Expected inbox for #{email_address} to be empty, but it contains #{all_emails.count} email(s).",
           "The last email has the subject line: '#{current_email.subject}'"].join("\n")
  end
  expect(all_emails).to be_empty, msg
end

Then(/^the inbox for '([\w@\.]+)' should contain an email with the subject '([\w ]+)'$/) do |email_address, expected_subject|
  open_email email_address
  expect(current_email.subject).to have_text expected_subject
end
