# Controller for the postal address
class PostalAddressController < ApplicationController
  include RegistrationsHelper

  # GET /your-registration/postal-address
  def show
    new_step_action 'postaladdress'
    @address = @registration.postal_address
  end

  # POST /your-registration/postal-address
  def create
    setup_registration 'postaladdress'
    return unless @registration

    if @registration.valid?

      if @registration.tier == 'LOWER'
        next_page = newConfirmation_path
      else
        next_page = registration_key_people_path
      end

      redirect_to next_page
    else
      # there is an error (but data not yet saved)
      logger.info 'Registration is not valid, and data is not yet saved'
      render 'show', status: '400'
    end
  end
end
