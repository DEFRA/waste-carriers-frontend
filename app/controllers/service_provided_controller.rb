class ServiceProvidedController < ApplicationController
  include RegistrationsHelper

  # GET /your-registration/service-provided
  def show
    new_step_action 'serviceprovided'
  end

  # POST /your-registration/service-provided
  def create
    setup_registration 'serviceprovided'
    return unless @registration

    if @registration.valid?
      case @registration.isMainService
      when 'yes'
        redirect_to :newOnlyDealWith
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
    :isMainService)
  end

end