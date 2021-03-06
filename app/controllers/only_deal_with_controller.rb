class OnlyDealWithController < ApplicationController
  include RegistrationsHelper

  # GET /your-registration/:reg_uuid/only-deal-with
  def show
    new_step_action 'onlydealwith'
    return unless @registration
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
      logger.debug 'Registration is not valid, and data is not yet saved'
      render 'show', status: :bad_request
    end

  end

  private

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment from UI web pages
  def registration_params
    params.require(:registration).permit(
    :onlyAMF)
  end

end
