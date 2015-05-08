class BusinessDetailsController < ApplicationController
  include BusinessDetailsHelper
  include RegistrationsHelper

  # GET /your-registration/business-details
  def show
    new_step_action 'businessdetails'
    @address = @registration.registered_address

    return unless 'address-results' == @address.address_mode

    # When here it is because a user has clicked the find address button
    if @address.valid?
      # valid in this instance means the postcode field was completed. We then
      # have something to search against.
      @address_match_list = AddressSearchResult.search(@address.postcode)

      # TODO: Understand what address_lookup_failure is used for
      session.delete(:address_lookup_failure) if session[:address_lookup_failure]
    else
      render 'show', status: '400'
    end
  end

  # POST /your-registration/business-details
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

    if params[:findAddress]
      # User clicked find address button

      # Setting the address mode to this helps determine what validations to
      # apply (see show action)
      @address.update_attributes(address_mode: 'address-results')

      # We update the postcode on the address so that it is retained when we
      # redirect to the page
      @address.update_attributes(postcode: params[:address][:postcode])
      @address.save
      redirect_to :business_details
    elsif @registration.selectedAddress
      # User clicked Continue button

      # We convert the selected address into an actual address object.
      selected_address = convert_selected_address

      # TODO: Understand why we note that address lookup was used in the session
      session[:address_lookup_selected] = true

      # Update the address object based on the selected address
      @address.populate_from_address_search_result(selected_address)

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
  end

  # GET /your-registration/business-details/edit
  def edit
    session[:edit_link_business_details] = '1'
    new_step_action 'businessdetails'
    @address = @registration.registered_address

    if @address.address_mode == 'manual-uk'
      redirect_to :business_details_manual
      return
    elsif @address.address_mode == 'manual-foreign'
      redirect_to :business_details_non_uk
      return
    else
      redirect_to :business_details
      return
    end
  end

  private

  def convert_selected_address
    # The address is returned in the format moniker::part1, part 2, etc.
    full_val = @registration.selectedAddress

    # This splits it into the 2 parts
    array = full_val.split('::')

    # part 1 contains the unique ID for the address
    moniker = array[0].to_s

    # part 2 contains the address as displayed in the drop down list. I believe
    # we capture it here so it can be used to reselect the option if you return
    # to the page.
    @registration.selectedAddress = array[1].to_s
    AddressSearchResult.search_by_id(moniker)
  end

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment
  # from UI web pages
  def registration_params
    params.require(:registration).permit(
    :company_no,
    :companyName)
  end
end
