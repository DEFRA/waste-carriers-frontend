class RegistrationMailer < ActionMailer::Base
  default from: "registrations@wastecarriersregistration.service.gov.uk"
  
  default :from => "\"EA Waste Carriers\" <registrations@wastecarriersregistration.service.gov.uk>"

  def welcome_email(user, registration)
  	@user = user
  	@url = ENV["WCRS_FRONTEND_PUBLIC_APP_DOMAIN"] || "www.wastecarriersregistration.service.gov.uk"
  	@registration = registration
    mail(to: @user.email, subject: 'Waste Carrier Registration Complete',
    	from: Rails.configuration.registrations_service_email,
    	reply_to: Rails.configuration.registrations_service_email)
  end
  
  def revoke_email(user, registration)
  	@user = user
  	@url = ENV["WCRS_FRONTEND_PUBLIC_APP_DOMAIN"] || "www.wastecarriersregistration.service.gov.uk"
  	@registration = registration
  	email_with_name = "EA Waste Registration <#{Rails.configuration.registrations_service_email}>"
    mail(to: @user.email, subject: 'The lower tier registration for '+@registration.companyName+' has been revoked. ',
    	from: email_with_name,
    	reply_to: Rails.configuration.registrations_service_email)
  end
  
end
