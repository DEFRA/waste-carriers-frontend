class BusinessDetailsController < ApplicationController
  include BusinessDetailsHelper
  include RegistrationsHelper

  # GET /your-registration/business-details
  def show
    new_step_action 'businessdetails'
    @address = @registration.registered_address

    return unless 'address-results' == @address.addressMode

    # When here it is because a user has clicked the find address button
    if @address.valid?
      # valid in this instance means the postcode field was completed. We then
      # have something to search against.
      @address_match_list = AddressSearchResult.search(@address.postcode)
    else
      logger.debug
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

    # Things are ordered in this way (below) to cover all possible combinations
    # of clicking the find and continue buttons, and ensuring the validations
    # work. For example checking for findAddress is first to cater for the user
    # having initially searched for an address then not liking the results so
    # searching again. If this wasn't first and if we didn't clear the address
    # mode then they would be stuck by the 'address_not_selected' validation
    # not letting them continue.

    if params[:findAddress]
      # User clicked find address button
      @address.update(addressMode: nil)
      if @registration.valid?
        # Setting the address mode to this helps determine what validations to
        # apply (see show action)
        @address.update_attributes(addressMode: 'address-results')

        # We update the postcode on the address so that it is retained when we
        # redirect to the page
        @address.update_attributes(postcode: params[:address][:postcode])
        @address.save
        redirect_to :business_details
        return
      end
    end

    unless @registration.selectedAddress.blank?
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

      # Don't specifically redirect here and leave it for the catch all at the
      # end of the method. This catchs an edge case identified in testing. If
      # a user chooses to edit their registration, then selects enter manually
      # and clicks ok, then selects edit again, this time chooses use postcode
      # lookup and then just clicks continue. With no catch all we'd get a
      # missing template error. As it is they are returned to the confirmation
      # page with no changes made to their address details.
    end

    unless @registration.valid?
      # We're here either because there is something wrong with the
      # registration. Either the company name has been left blank or if the line
      # below is activated its because the user never selected an address from
      # the results returned.
      if 'address-results' == @address.addressMode
        @address_match_list = AddressSearchResult.search(@address.postcode)
      end
      render 'show', status: '400'
      return
    end

    # Else someone clicked continue without having entered a postcode so we
    # want to validate the address to record the postcode error before
    # returning the page back.
    unless @address.valid?
      render 'show', status: '400'
      return
    end

    # This is a call into a method in the Bus Dtls helper. It looks at a value
    # in the session to determine if we need to go to the next step in the
    # application or back to the confirmation page
    redirect_to redirect_to?
  end

  # GET /your-registration/business-details/edit
  def edit
    session[:edit_link_business_details] = '1'
    new_step_action 'businessdetails'
    @address = @registration.registered_address

    if @address.addressMode == 'manual-uk'
      redirect_to :business_details_manual
      return
    elsif @address.addressMode == 'manual-foreign'
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

    # part 1 contains the unique ID for the address (part 2 is what gets
    # displayed in the lookup list)
    moniker = array[0].to_s

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
