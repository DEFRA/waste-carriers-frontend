# Implements service-specific customisations to the Devise 'Authenticatable'
# behaviour, specifically, the page they are redirected to after they request
# new password reset instructions.
class PasswordsController < Devise::PasswordsController
  # After we send somebody password reset instructions, should we redirect
  # them to the normal sign-in page, or the sign-in page that is shown mid-way
  # through a new registration?
  def after_sending_reset_password_instructions_path_for(resource_name)
    redirect_to = super
    if resource_name == :user && session.key?(:at_mid_registration_signin_step)
      redirect_to = newSignin_path
    end
    redirect_to
  end
end
