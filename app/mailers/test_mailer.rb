# frozen_string_literal: true

class TestMailer < ActionMailer::Base

  FROM_ADDRESS = "Waste carriers test service"
  SUBJECT = "Waste Carriers test email"
  IMAGE_NAME = "govuk_logotype_email.png"

  def base_email(recipient, body = nil)
    body = "Test email" if body.nil?
    mail(to: recipient, subject: SUBJECT, from: FROM_ADDRESS, body: body)
  end

  def basic_text_email(recipient, body = nil)
    body = "Test email" if body.nil?
    mail(to: recipient, subject: SUBJECT, from: FROM_ADDRESS, content_type: "text/plain", body: body)
  end

  def basic_html_email(recipient, body = nil)
    body = "<h1>Test email</h1>" if body.nil?
    mail(to: recipient, subject: SUBJECT, from: FROM_ADDRESS, content_type: "text/html", body: body)
  end

  def multipart_text_email(recipient)
    # We have to add an attachment to force actionmailer to create a multipart
    # email, else it will just generate a base plain text email.
    add_logo_attachment
    mail(to: recipient, subject: SUBJECT, from: FROM_ADDRESS) do |format|
      format.text { render "test_email" }
    end
  end

  def multipart_html_email(recipient)
    # We have to add an attachment to force actionmailer to create a multipart
    # email, else it will just generate a base html email.
    add_logo_attachment
    mail(to: recipient, subject: SUBJECT, from: FROM_ADDRESS) do |format|
      format.html { render "test_email" }
    end
  end

  def multipart_email(recipient)
    # We have to add an attachment to force actionmailer to create a multipart
    # email, else it will just generate a base html email.
    add_logo_attachment
    mail(to: recipient, subject: SUBJECT, from: FROM_ADDRESS) do |format|
      format.text { render "test_email" }
      format.html { render "test_email" }
    end
  end

  private

  def add_logo_attachment
    path = Rails.root.join("app/assets/images/#{IMAGE_NAME}")
    attachments[IMAGE_NAME] = File.read(path)
  end

end
