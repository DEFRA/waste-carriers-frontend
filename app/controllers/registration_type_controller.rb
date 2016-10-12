class RegistrationTypeController < ApplicationController
  include RegistrationsHelper

  # GET /your-registration/:reg_uuid/registration-type
  def show
    new_step_action 'registrationtype'
    return unless @registration
  end

  # GET /your-registration/:reg_uuid/registration-type/edit
  def edit
    new_step_action 'registrationtype'
    return unless @registration
    
    session[:edit_link_reg_type] = @registration.reg_uuid

    render 'show'
  end

  # POST /your-registration/registration-type
  def create
    setup_registration 'registrationtype'
    return unless @registration

    if @registration.valid?
      if session[:edit_link_reg_type] == @registration.reg_uuid
        session.delete(:edit_link_reg_type)
        redirect_to :confirmation
        return
      else
        redirect_to :business_details
        return
      end
    else
      # there is an error (but data not yet saved)
      logger.debug 'Registration is not valid, and data is not yet saved'
      render 'show', status: :bad_request
    end
  end

  private

  # 'strong parameters' - whitelisting parameters allowed for mass assignment
  # from UI web pages
  def registration_params
    params.require(:registration).permit(:registrationType)
  end
end
