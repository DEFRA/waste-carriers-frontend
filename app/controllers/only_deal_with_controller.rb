class OnlyDealWithController < ApplicationController
  include RegistrationsHelper

  # GET /your-registration/only-deal-with
  def show
    new_step_action 'onlydealwith'
  end

  # POST /your-registration/only-deal-with
  def create
    setup_registration 'onlydealwith'
    return unless @registration

    if @registration.valid?

      case @registration.onlyAMF
      when 'yes'
        proceed_as_lower
      when 'no'
        proceed_as_upper
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
    :onlyAMF)
  end

end
