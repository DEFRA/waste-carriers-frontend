class StartController < ApplicationController
  include RegistrationsHelper

  # GET /registrations/start
  def show
    reg_uuid = params[:reg_uuid]
    @registration = if reg_uuid.present?
      # Edit an existing registration
      Registration.find(reg_uuid: reg_uuid).first
    else
      # Create a new registration
      Registration.ctor(agency_user_signed_in: agency_user_signed_in?)
    end
    return unless @registration
  end

  # POST /registrations/start
  def create
    setup_registration 'newOrRenew'
    return unless @registration

    if @registration.valid?
      case @registration.newOrRenew
      when 'renew'
        #These :ga_... are used for Google Analytics
        session[:ga_is_renewal] = true
        redirect_to :existing_registration
        return
      when 'new'
        session[:ga_is_renewal] = false
        redirect_to :business_type
        return
      end
    end

    # there is an error (but data not yet saved)
    logger.debug 'No selection made'
    render 'show', status: :bad_request

  end

  private

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment from UI web pages
  def registration_params
    params.require(:registration).permit(
    :newOrRenew)
  end

end
