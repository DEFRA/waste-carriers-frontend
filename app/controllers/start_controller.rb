class StartController < ApplicationController
  include RegistrationsHelper

  # GET /registrations/start
  def show
    begin_steps(params[:reg_uuid])
    # new_step_action 'newOrRenew'
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
    render 'show', :status => '400'

  end

  private

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment from UI web pages
  def registration_params
    params.require(:registration).permit(
    :newOrRenew)
  end

end
