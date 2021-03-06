class BusinessTypeController < ApplicationController
  include RegistrationsHelper

  # GET /your-registration/:reg_uuid/business-type
  def show
    new_step_action 'businesstype'
    return unless @registration
  end

  # POST /your-registration/business-type
  def create
    setup_registration 'businesstype'
    return unless @registration

    if @registration.valid?

      case @registration.businessType
      when 'soleTrader', 'partnership', 'limitedCompany', 'publicBody'
        redirect_to :other_businesses
      when 'charity', 'authority'
        proceed_as_lower
      when 'other'
        redirect_to :no_registration
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
      :businessType)
    end

end
