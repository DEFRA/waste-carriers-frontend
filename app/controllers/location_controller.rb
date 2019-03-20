class LocationController < ApplicationController
  include RegistrationsHelper

  # GET /your-registration/:reg_uuid/location
  def show
    new_step_action 'location'
    return unless @registration
  end

  # POST/your-registration/location
  def create
    setup_registration 'location'
    return unless @registration

    if @registration.valid?
      case @registration.location
      when 'england'
        redirect_to :business_type
      when 'wales'
        redirect_to :register_in_wales
      when 'scotland'
        redirect_to :register_in_scotland
      when 'northern_ireland'
        redirect_to :register_in_northern_ireland
      when 'overseas'
        redirect_to :business_type
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
    params.require(:registration).permit(:location)
  end
end