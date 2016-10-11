class BusinessDetailsNonUkController < ApplicationController
  include BusinessDetailsHelper
  include RegistrationsHelper

  # GET /your-registration/:reg_uuid/business-details-non-uk
  def show
    new_step_action 'businessdetails'
    return unless @registration
    @address = @registration.registered_address
  end

  # POST /your-registration/business-details-non-uk
  def create
    setup_registration 'businessdetails'
    return unless @registration

    # Reset the selectedAddress value on the registration. This is used in
    # conjuntion with the lookup logic and can cause issues with the business
    # details controller (should the use switch back) if left in place.
    @registration.update(selectedAddress: nil)

    # You must get the address object before the possibility of returning to the
    # view as the view expects an instantiated address.
    @address = @registration.registered_address

    # Clear the existing address and then update it based on the mode we're in
    # and the data posted from the form
    @address.clear
    @address.update_attributes(addressMode: 'manual-foreign')
    @address.update_attributes(params[:address])
    @address.save

    unless @registration.valid? && @address.valid?
      render 'show', status: '400'
      return
    end

    # If the registration is upper tier we run a conviction check against
    # the company name.
    unless @registration.tier.eql? 'LOWER'
      @registration.cross_check_convictions
      @registration.save
    end

    # This is a call into a method in the Bus Dtls helper. It looks at a value
    # in the session to determine if we need to go to the next step in the
    # application or back to the confirmation page
    redirect_to redirect_to?
  end

  private

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment
  # from UI web pages
  def registration_params
    params.require(:registration).permit(:company_no, :companyName)
  end
end
