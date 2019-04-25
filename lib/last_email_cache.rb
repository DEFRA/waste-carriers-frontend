# frozen_string_literal: true

require "singleton"
require "json"

class LastEmailCache
  include Singleton

  EMAIL_ATTRIBUTES = %i[date from to bcc cc reply_to subject].freeze

  attr_accessor :last_email

  def self.delivering_email(message)
    instance.last_email = message
  end

  # This is necessary to properly test the service functionality
  def reset
    @last_email = nil
  end

  def last_email_json
    return JSON.generate(error: "No emails sent.") unless last_email.present?

    message_hash = {}
    EMAIL_ATTRIBUTES.each do |attribute|
      message_hash[attribute] = last_email.public_send(attribute)
    end
    message_hash[:body] = email_body
    message_hash[:attachments] = last_email.attachments.map(&:filename)

    JSON.generate(last_email: message_hash)
  end

  private

  # If you've set multipart emails then you'll have both a text and a html
  # version (determined by adding the relevant erb views). If you do so then
  # `my_mail.parts.length` will equal 2. If however you only have the one then
  # `parts` doesn't seem to get populated. To cater for this we have this
  # method to grab the body content
  # https://guides.rubyonrails.org/action_mailer_basics.html#sending-multipart-emails
  def email_body
    return last_email.body.to_s if last_email.parts.empty?

    last_email.text_part.to_s
  end
end
