class ConfirmationsController < Devise::ConfirmationsController

  private

  def after_confirmation_path_for(resource_name, resource)

    Registration.activate_registrations(resource)

  	#Temporarily storing the confirmed user in the session to be picked up from the registrations controller
    session[:confirmed_user] = resource

    # This is a variable that represents the page to be redirected to after the verification link
    confirmed_path
  end

end