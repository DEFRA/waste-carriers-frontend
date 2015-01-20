class OtherBusinessesController < ApplicationController
  include RegistrationsHelper

  # GET /your-registration/other-businesses
  def show
    new_step_action 'otherbusinesses'
  end

  # POST /your-registration/other-businesses
  def create
    setup_registration 'otherbusinesses'
    return unless @registration

    if @registration.valid?
      case @registration.otherBusinesses
      when 'yes'
        redirect_to :service_provided
      when 'no'
        redirect_to :newConstructionDemolition
      end
    else
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render 'show', :status => '400'
    end

  end

  private

    ## 'strong parameters' - whitelisting parameters allowed for mass assignment from UI web pages
    def registration_params
      params.require(:registration).permit(
      :otherBusinesses)
    end

end
