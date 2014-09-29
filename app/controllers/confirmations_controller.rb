class ConfirmationsController < Devise::ConfirmationsController

  private

  def after_confirmation_path_for(resource_name, resource)

    Registration.activate_registrations(resource)

  	#Temporarily storing the confirmed user in the session to be picked up from the registrations controller
    session[:user] = resource

    # This is a variable that represents the page to be redirected to after the verification link
    registrations = Registration.find_by_email(@user.email)
    unless registrations.empty?
    
      sorted = registrations.sort_by { |r| r.date_registered}.reverse!
      registration = sorted.first
      session[:registration_uuid] = registration.uuid
      
      if registration.tier.eql? 'LOWER'
        goto_page = confirmed_path
      else
        goto_page = new_user_session_path
      end
    else
      flash[:notice] = 'Registration list is empty, Found no registrations for user: ' + @user.email.to_s       
      ## todo put here path to sign in page
      goto_page = new_user_session_path
    end
    goto_page
  end

end
