class BusinessDetailsManualController < ApplicationController
  include RegistrationsHelper

  # GET /your-registration/business-details-manual
  def show
    new_step_action 'businessdetails'
    @address = @registration.registered_address
  end

  # POST /your-registration/business-details-manual
  def create
    setup_registration 'businessdetails'
    return unless @registration

    # You must get the address object before the possibility of returning to the
    # view as the view expects an instantiated address.
    @address = @registration.registered_address

    unless @registration.valid?
      render 'show', status: '400'
      return
    end

    @address.clear
    @address.update_attributes(address_mode: 'manual-uk')
    @address.update_attributes(params[:address])
    @address.save

    unless @address.valid?
      render 'show', status: '400'
      return
    end

    redirect_to :newContact
  end

  private

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment
  # from UI web pages
  def registration_params
    params.require(:registration).permit(
    :company_no,
    :companyName)
  end
end
