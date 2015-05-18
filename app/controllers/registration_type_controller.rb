class RegistrationTypeController < ApplicationController
  include RegistrationsHelper

  # GET /your-registration/registration-type
  def show
    new_step_action 'registrationtype'
  end

  # GET /your-registration/registration-type/edit
  def edit
    session[:edit_link_reg_type] = '1'
    new_step_action 'registrationtype'
    render 'show'
  end

  # POST /your-registration/registration-type
  def create
    setup_registration 'registrationtype'
    return unless @registration

    if @registration.valid?
      if session[:edit_link_reg_type]
        session.delete(:edit_link_reg_type)
        redirect_to :newConfirmation
        return
      else
        redirect_to :business_details
        return
      end
    else
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render 'show', status: '400'
    end
  end

  private

  # 'strong parameters' - whitelisting parameters allowed for mass assignment
  # from UI web pages
  def registration_params
    params.require(:registration).permit(:registrationType)
  end
end
