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

    # Clear the existing address and then update it based on the mode we're in
    # and the data posted from the form
    @address.clear
    @address.update_attributes(address_mode: 'manual-uk')
    @address.update_attributes(params[:address])
    @address.save

    unless @address.valid?
      render 'show', status: '400'
      return
    end

    # If the registration is upper tier we run a conviction check against
    # the company name.
    unless @registration.tier.eql? 'LOWER'
      @registration.cross_check_convictions
      @registration.save
    end

    redirect_to :newContact
  end

  private

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment
  # from UI web pages
  def registration_params
    params.require(:registration).permit(:company_no, :companyName)
  end
end
