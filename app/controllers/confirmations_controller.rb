class ConfirmationsController < Devise::ConfirmationsController

  private

  def after_confirmation_path_for(resource_name, resource)
    # This is a variable that represents the page to be redirected to after the verification link
    confirmed_path
  end

end