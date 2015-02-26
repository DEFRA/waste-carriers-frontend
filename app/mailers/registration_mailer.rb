class RegistrationMailer < ActionMailer::Base
  helper :application
  helper :registrations
  default from: "registrations@wastecarriersregistration.service.gov.uk"

  # This line should have set the defailt from name, but didnt in testing,
  # as such email_with_name variables were created to pass in the email name
  #default :from => "\"EA Waste Carriers\" <registrations@wastecarriersregistration.service.gov.uk>"

  def welcome_email(user, registration)
    @user = user
    @url = ENV["WCRS_FRONTEND_PUBLIC_APP_DOMAIN"] || "www.wastecarriersregistration.service.gov.uk"
    @registration = registration
    email_with_name = "#{Rails.configuration.registrations_service_emailName} <#{Rails.configuration.registrations_service_email}>"
    mail(to: @user.email, subject: I18n.t('global.mailer.complete.subject'),
      from: email_with_name,
      reply_to: Rails.configuration.registrations_service_email)
  end

  # Call via: RegistrationMailer.awaitingPayment_email(@user, @registration).deliver
  def awaitingPayment_email(user, registration)
    @user = user
    @url = ENV["WCRS_FRONTEND_PUBLIC_APP_DOMAIN"] || "www.wastecarriersregistration.service.gov.uk"
    @registration = registration
    email_with_name = "#{Rails.configuration.registrations_service_emailName} <#{Rails.configuration.registrations_service_email}>"
    subjectMessage = I18n.t('global.mailer.payment.subject',:tier=>@registration.tier.downcase, :companyName=>@registration.companyName)
    mail(to: @user.email, subject: subjectMessage,
      from: email_with_name,
      reply_to: Rails.configuration.registrations_service_email)
  end

  # Call via: RegistrationMailer.awaitingConvictionsCheck_email(@user, @registration).deliver
  def awaitingConvictionsCheck_email(user, registration)
    @user = user
    @url = ENV["WCRS_FRONTEND_PUBLIC_APP_DOMAIN"] || "www.wastecarriersregistration.service.gov.uk"
    @registration = registration
    email_with_name = "#{Rails.configuration.registrations_service_emailName} <#{Rails.configuration.registrations_service_email}>"
    subjectMessage = I18n.t('global.mailer.convictions.subject',:tier=>@registration.tier.downcase, :companyName=>@registration.companyName)
    mail(to: @user.email, subject: subjectMessage,
      from: email_with_name,
      reply_to: Rails.configuration.registrations_service_email)
  end

  # Call via: RegistrationMailer.account_already_confirmed_email(user, is_mid_registration).deliver
  def account_already_confirmed_email(user, is_mid_registration)
    @is_mid_registration = is_mid_registration
    mail(
      to: user.email,
      subject: I18n.t('registration_mailer.account_already_confirmed.title'),
      from: "#{Rails.configuration.registrations_service_emailName} <#{Rails.configuration.registrations_service_email}>",
      reply_to: Rails.configuration.registrations_service_email)
  end
end
