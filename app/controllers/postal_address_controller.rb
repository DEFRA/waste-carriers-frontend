# Controller for the postal address
class PostalAddressController < ApplicationController
  include PostalAddressHelper
  include RegistrationsHelper

  # GET /your-registration/postal-address
  def show
    new_step_action 'postaladdress'
    return unless @registration
    @address = @registration.postal_address

    unless set?(@address)
      populate_from_registered_address!(@registration, @address)
    end
  end

  # GET /your-registration/postal-address/edit
  def edit
    session[:edit_link_postal_address] = '1'
    new_step_action 'postaladdress'
    return unless @registration

    redirect_to :postal_address
  end

  # POST /your-registration/postal-address
  def create
    setup_registration 'postaladdress'
    return unless @registration

    @address = @registration.postal_address

    # Clear the existing address and then update it based on the data posted
    # from the form
    @address.clear
    @address.update_attributes(params[:address])
    @address.save

    if @address.valid?

      if @registration.tier == 'LOWER'
        next_page = newConfirmation_path
      else
        next_page = registration_key_people_path
      end

      redirect_to redirect_to?(@registration.tier)
    else
      # there is an error (but data not yet saved)
      logger.debug 'Registration is not valid, and data is not yet saved'
      render 'show', status: '400'
    end
  end
end
