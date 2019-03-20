class RegisterInWalesController < ApplicationController
  include RegistrationsHelper

  # GET /your-registration/:reg_uuid/register-in-wales
  def show
    new_step_action 'register_in_wales'
    return unless @registration
  end

  # POST/your-registration/register-in-wales
  def create
    setup_registration 'register_in_wales'
    return unless @registration

    if @registration.valid?
      redirect_to :business_type
    else
      # there is an error (but data not yet saved)
      logger.debug 'Registration is not valid, and data is not yet saved'
      render 'show', status: :bad_request
    end
  end

end
