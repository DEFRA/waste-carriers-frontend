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
  # `my_mail.parts.length` will at least equal 2. If you only have one of them
  # e.g. just a text version then parts doesn't get populated.
  #
  # However any attachments will cause ActionMailer to use parts. So for example
  # if we have a text only email with an attached image, then parts will be of
  # length 2; one being the content and the other being the attachment.
  #
  # To cater for all possibilities we have this method to grab the body content
  # https://guides.rubyonrails.org/action_mailer_basics.html#sending-multipart-emails
  # https://stackoverflow.com/a/15818886
  def email_body
    part_to_use = last_email.text_part || last_email.html_part || last_email

    # return the message body without the header information
    part_to_use.body.decoded
  end
end
