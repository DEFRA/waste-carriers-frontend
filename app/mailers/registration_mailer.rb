class RegistrationMailer < ActionMailer::Base
  helper :application
  helper :registrations
  add_template_helper(EmailHelper)

  def welcome_email(user, registration)
    @user = user
    @url = Rails.configuration.subdomain
    @registration = registration
    @pdf = true
    from_address = "#{Rails.configuration.registrations_service_emailName} <#{Rails.configuration.registrations_service_email}>"
    subject = I18n.t('global.mailer.complete.subject')
    attachments["WasteCarrierRegistrationCertificate-#{registration.regIdentifier}.pdf"] = WickedPdf.new.pdf_from_string(
      render_to_string(pdf: 'certificate', template: 'registrations/certificate', layout: 'pdf.html.erb'),
      {}
    )
    mail(to: @user.email, subject: subject, from: from_address)
  end

  # Call via: RegistrationMailer.awaitingPayment_email(@user, @registration).deliver_now
  def awaitingPayment_email(user, registration)
    @user = user
    @url = Rails.configuration.subdomain
    @registration = registration
    from_address = "#{Rails.configuration.registrations_service_emailName} <#{Rails.configuration.registrations_service_email}>"
    subject = I18n.t('global.mailer.payment.subject', tier: @registration.tier.downcase, companyName: @registration.companyName)
    mail(to: @user.email, subject: subject, from: from_address)
  end

  # Call via: RegistrationMailer.awaitingConvictionsCheck_email(@user, @registration).deliver_now
  def awaitingConvictionsCheck_email(user, registration)
    @user = user
    @url = Rails.configuration.subdomain
    @registration = registration
    from_address = "#{Rails.configuration.registrations_service_emailName} <#{Rails.configuration.registrations_service_email}>"
    subject = I18n.t('global.mailer.convictions.subject', tier: @registration.tier.downcase, companyName: @registration.companyName)
    mail(to: @user.email, subject: subject, from: from_address)
  end

  # Call via: RegistrationMailer.account_already_confirmed_email(user, is_mid_registration).deliver_now
  def account_already_confirmed_email(user, is_mid_registration)
    @is_mid_registration = is_mid_registration
    from_address = "#{Rails.configuration.registrations_service_emailName} <#{Rails.configuration.registrations_service_email}>"
    subject = I18n.t('registration_mailer.account_already_confirmed.title')
    mail(to: user.email, subject: subject, from: from_address)
  end

  def test_email
    from_address = "#{Rails.configuration.registrations_service_emailName} <#{Rails.configuration.registrations_service_email}>"
    subject = "Waste Carriers Test email"
    mail(to: Rails.configuration.email_test_address, subject: subject, from: from_address) do |format|
      format.text(content_type: "text/plain", charset: "UTF-8", content_transfer_encoding: "7bit")
    end
  end
end
