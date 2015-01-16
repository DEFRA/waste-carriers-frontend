class BusinessTypeController < ApplicationController
  include RegistrationsHelper

  # GET /your-registration/business-type
  def show

    new_step_action 'businesstype'
    logger.debug "Route is #{@registration.metaData.first.route}"

  end

  # POST /your-registration/business-type
  def create
    setup_registration 'businesstype'
    return unless @registration

    if @registration.valid?

      case @registration.businessType
      when 'soleTrader', 'partnership', 'limitedCompany', 'publicBody'
        redirect_to :newOtherBusinesses
      when 'charity', 'authority'
        proceed_as_lower
      when 'other'
        redirect_to :newNoRegistration
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
      :businessType)
    end

end
