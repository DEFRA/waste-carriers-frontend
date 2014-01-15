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
    mail(to: @user.email, subject: 'Waste Carrier Registration Complete',
    	from: email_with_name,
    	reply_to: Rails.configuration.registrations_service_email)
  end
  
  def revoke_email(user, registration)
  	@user = user
  	@url = ENV["WCRS_FRONTEND_PUBLIC_APP_DOMAIN"] || "www.wastecarriersregistration.service.gov.uk"
  	@registration = registration
  	email_with_name = "#{Rails.configuration.registrations_service_emailName} <#{Rails.configuration.registrations_service_email}>"
    mail(to: @user.email, subject: 'The lower tier registration for '+@registration.companyName+' has been revoked. ',
    	from: email_with_name,
    	reply_to: Rails.configuration.registrations_service_email)
  end
  
end
