# Controller for the postal address
class PostalAddressController < ApplicationController
  include PostalAddressHelper
  include RegistrationsHelper

  # GET /your-registration/:reg_uuid/postal-address
  def show
    new_step_action 'postaladdress'
    return unless @registration
    @address = @registration.postal_address

    unless set?(@address)
      populate_from_registered_address!(@registration, @address)
    end
  end

  # GET /your-registration/:reg_uuid/postal-address/edit
  def edit
    new_step_action 'postaladdress'
    return unless @registration

    session[:edit_link_postal_address] = @registration.reg_uuid # Needs to be unique per registration

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

      # We need to determine whether the user arrived at the page as part of the
      # application process, or by choosing to edit their details on the
      # confirmation page. Determining this is based on whether
      # edit_link_postal_address exists in the session.
      if session[:edit_link_postal_address] == @registration.reg_uuid
        session.delete(:edit_link_postal_address)
        next_page = confirmation_path(@registration.reg_uuid)
      elsif @registration.tier == 'LOWER'
        next_page = confirmation_path(@registration.reg_uuid)
      else
        next_page = registration_key_people_path(@registration.reg_uuid)
      end

      redirect_to(next_page)

    else
      # there is an error (but data not yet saved)
      logger.debug 'Registration is not valid, and data is not yet saved'
      render 'show', status: :bad_request
    end
  end
end
