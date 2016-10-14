# Implements service-specific customisations to the Devise 'Confirmable'
# behaviour, specifically, how this service behaves when a user:
#   * confirms their email address;
#   * ask for new confirmation instructions.
# Generally this involves customising the emails that are send, and the page the
# user is redirected to after an email is sent.
class ConfirmationsController < Devise::ConfirmationsController
  # Override the normal "create" behaviour, so that we send a customised email
  # when people who have already confirmed their account request
  # re-confirmation instructions.
  def create
    if (resource_class == User) && resource_params.key?('email')
      user = User.find_by_email(resource_params['email'])
      if user && user.confirmed?
        RegistrationMailer.account_already_confirmed_email(user,
            session.key?(:at_mid_registration_signin_step)).deliver_now
      end
    end
    super
  end

  private

  def after_confirmation_path_for(resource_name, resource)
    # In case the account has been locked prior to confirmation, unlock it now.
    @user.unlock_access!

    user_registrations = Registration.activate_registrations(resource)

    # Temporarily storing the email address of the confirmed user in the session
    # to be picked up from the registrations controller.
    session[:userEmail] = resource.email

    # This is a variable that represents the page to be redirected to after the
    # verification link
    if user_registrations.empty?
      flash[:notice] = 'Found no registrations for user: ' + @user.email.to_s
      goto_page = new_user_session_path
    else
      sorted = user_registrations.sort_by { |r| r.date_registered }.reverse!
      registration = sorted.first

      #session[:registration_uuid] = registration.uuid

      goto_page = if registration.tier == 'LOWER'
         confirmed_path(reg_uuid: registration.reg_uuid)
      else
        account_confirmed_path(reg_uuid: registration.reg_uuid)
      end
    end
    goto_page
  end

  # After we send somebody account confirmation instructions, should we redirect
  # them to the normal sign-in page, or the sign-in page that is shown mid-way
  # through a new registration?
  def after_resending_confirmation_instructions_path_for(resource_name)
    redirect_to = super
    if resource_name == :user && session.key?(:at_mid_registration_signin_step)
      redirect_to = signin_path(reg_uuid: session[:at_mid_registration_signin_step])
    end
    redirect_to
  end
end
