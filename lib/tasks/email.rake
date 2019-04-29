# frozen_string_literal: true

namespace :email do
  desc "Send a test email to confirm setup is correct"
  task test: :environment do
    recipient = ENV["WCRS_EMAIL_TEST_ADDRESS"] || "waste-carriers@example.com"
    puts TestMailer.basic_text_email(recipient).deliver_now
  end
end
