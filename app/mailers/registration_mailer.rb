class RegistrationMailer < ActionMailer::Base
  default from: "registration@wastecarriersregistration.service.gov.uk"

  def welcome_email(user, registration)
  	@user = user
  	@url = ENV["WCRS_FRONTEND_PUBLIC_APP_DOMAIN"] || "www.wastecarriersregistration.service.gov.uk"
  	@registration = registration
    mail(to: @user.email, subject: 'Registration Complete for a Waste Carrier!',
    	reply_to: Rails.configuration.registrations_service_email)
  end
  
end
