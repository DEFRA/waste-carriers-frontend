class RegistrationMailer < ActionMailer::Base
  default from: "waste-carrier-registrations@example.com"

  def welcome_email(user)
  	@user = user
  	@url = 'http://37.26.89.99/registrations'
    mail(to: @user.email, subject: 'Welcome to Waste Carrier Registrations!')
  end
  
end
