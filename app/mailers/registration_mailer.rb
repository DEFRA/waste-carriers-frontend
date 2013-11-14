class RegistrationMailer < ActionMailer::Base
  default from: "registration@wastecarriersregistration.service.gov.uk"

  def welcome_email(user, registration)
  	@user = user
  	@url = Rails.configuration.waste_exemplar_frontend_url
  	@registration = registration
    mail(to: @user.email, subject: 'Registration Complete for a Waste Carrier!',
    	reply_to: 'TODO-wastecarriersregistration@environment-agency.gov.uk')
  end
  
end
