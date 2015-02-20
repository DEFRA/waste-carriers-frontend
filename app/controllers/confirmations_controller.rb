class ConfirmationsController < Devise::ConfirmationsController
  # Override the normal "create" behaviour, so that we send a customised email
  # when people who have already confirmed their account request
  # re-confirmation instructions.
  def create
    if (resource_class == User) && resource_params.key?('email')
      user = User.find_by_email(resource_params['email'])
      if user && user.confirmed?
        RegistrationMailer.account_already_confirmed_email(user).deliver
      end
    end
    super
  end

  private

  def after_confirmation_path_for(resource_name, resource)
    # In case the account has been locked prior to confirmation, unlock it now.
    @user.unlock_access!

    Registration.activate_registrations(resource)

    # Temporarily storing the confirmed user in the session to be picked up from
    # the registrations controller
    session[:user] = resource

    # This is a variable that represents the page to be redirected to after the
    # verification link
    registrations = Registration.find_by_email(@user.email)
    if registrations.empty?
      flash[:notice] = 'Registration list is empty, Found no registrations for user: ' + @user.email.to_s
      ## todo put here path to sign in page
      goto_page = new_user_session_path
    else
      sorted = registrations.sort_by { |r| r.date_registered }.reverse!
      registration = sorted.first
      session[:registration_uuid] = registration.uuid
      if registration.tier.eql? 'LOWER'
        goto_page = confirmed_path
      else
        goto_page = account_confirmed_path
      end
    end
    goto_page
  end
end
