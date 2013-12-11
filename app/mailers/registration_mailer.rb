class RegistrationMailer < ActionMailer::Base
  default from: "registrations@wastecarriersregistration.service.gov.uk"

  def welcome_email(user, registration)
  	@user = user
  	@url = ENV["WCRS_FRONTEND_PUBLIC_APP_DOMAIN"] || "www.wastecarriersregistration.service.gov.uk"
  	@registration = registration
    mail(to: @user.email, subject: 'Waste Carrier Registration Complete',
    	from: Rails.configuration.registrations_service_email,
    	reply_to: Rails.configuration.registrations_service_email)
  end
  
end
