class RegistrationMailer < ActionMailer::Base
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


  ## TODO - Replace with helper or decorator
  def format_date(string)
    d = string.to_date
    d.strftime('%A ' + d.mday.ordinalize + ' %B %Y')
  end

end
