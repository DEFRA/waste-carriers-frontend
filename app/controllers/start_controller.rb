class StartController < ApplicationController
  include RegistrationsHelper

  # GET /registrations/start
  def show
    new_step_action 'newOrRenew'
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
        redirect_to :enterRegistration
      when 'new'
        session[:ga_is_renewal] = false
        redirect_to business_type_url
      end
    else
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      @registration.errors.add(:newOrRenew, I18n.t('errors.messages.blank'))
      render 'show', :status => '400'
    end

  end

  private

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment from UI web pages
  def registration_params
    params.require(:registration).permit(
    :newOrRenew)
  end

end
