# Implements service-specific customisations to the Devise 'Authenticatable'
# behaviour, specifically, the page they are redirected to after they:
#    * request new password reset instructions
#    * update their password
class PasswordsController < Devise::PasswordsController
  # After we send somebody password reset instructions, should we redirect
  # them to the normal sign-in page, or the sign-in page that is shown mid-way
  # through a new registration?
  def after_sending_reset_password_instructions_path_for(resource_name)
    redirect_to = super
    if resource_name == :user && session.key?(:at_mid_registration_signin_step)
      redirect_to = signin_path(reg_uuid: session[:at_mid_registration_signin_step])
    end
    redirect_to
  end

  # After a user updates their password, should we redirect them to the normal
  # 'your registrations' page (with the user signed-in), or quietly sign them
  # out so they can continue with a registration in another window?
  def after_resetting_password_path_for(resource)
    redirect_to = super
    if resource && session.key?(:at_mid_registration_signin_step)
      # We don't want to destroy the session, because the user is in the middle
      # of a new registration.  Session time-out will handle the cases where
      # the user doesn't return to their original tab / window.
      sign_out resource
      redirect_to = mid_registration_password_changed_path(reg_uuid: session[:at_mid_registration_signin_step])
    end
    redirect_to
  end
end
