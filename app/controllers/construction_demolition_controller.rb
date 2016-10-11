class ConstructionDemolitionController < ApplicationController
  include RegistrationsHelper

  # GET /your-registration/:reg_uuid/construction-demolition
  def show
    new_step_action 'constructiondemolition'
    return unless @registration
  end

  # POST /your-registration/construction-demolition
  def create
    setup_registration 'constructiondemolition'
    return unless @registration

    if @registration.valid?

      case @registration.constructionWaste
      when 'yes'
        proceed_as_upper
      when 'no'
        proceed_as_lower
      end
    else
      # there is an error (but data not yet saved)
      logger.debug 'Registration is not valid, and data is not yet saved'
      render 'show', :status => '400'
    end

  end

  private

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment from UI web pages
  def registration_params
    params.require(:registration).permit(
    :constructionWaste)
  end

end
