class RegistrationMailer < ActionMailer::Base
  default from: "waste-carrier-registrations@example.com"

  def welcome_email(user, registration)
  	@user = user
  	@url = 'http://37.26.89.99/registrations'
  	@registration = registration
    mail(to: @user.email, subject: 'Registration Complete for a Waste Carrier!')
  end
  
end
