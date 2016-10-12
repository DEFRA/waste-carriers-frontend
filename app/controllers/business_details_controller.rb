class BusinessDetailsController < ApplicationController
  include BusinessDetailsHelper
  include RegistrationsHelper

  # GET /your-registration/:reg_uuid/business-details
  def show
    new_step_action 'businessdetails'
    return unless @registration
    @address = @registration.registered_address

    # Because we persist the addressMode we can use it when a user wishs to
    # edit their address to present the correct edit view. However if they
    # wish to switch to using address lookup, our logic for determing that
    # is that the addressMode is blank (or set to address-results). This means
    # we need a way of removing the current addressMode when the user wishes to
    # move from an manual address to address lookup
    @address.update(addressMode: nil) if params[:use_postcode]

    go_to = confirm_route(@address.addressMode)
    redirect_to(go_to) unless go_to == business_details_path

    return unless 'address-results' == @address.addressMode

    # When here it is because a user has clicked the find address button
    if @address.valid?
      # valid in this instance means the postcode field was completed. We then
      # have something to search against.
      @address_match_list = AddressSearchResult.search(@address.postcode)
    else
      render 'show', status: :bad_request
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
      selected_address = AddressSearchResult.search_by_id(@registration.selectedAddress)

      # TODO: Understand why we note that address lookup was used in the session
      # session [:address_lookup_selected] = true

      # Update the address object based on the selected address
      @address.populate_from_address_search_result(selected_address)

      # If the registration is upper tier we run a conviction check against
      # the company name.
      unless @registration.tier == 'LOWER'
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
      render 'show', status: :bad_request
      return
    end

    # Else someone clicked continue without having entered a postcode so we
    # want to validate the address to record the postcode error before
    # returning the page back.
    unless @address.valid?
      render 'show', status: :bad_request
      return
    end

    # This looks at a value to determine if we need to go to the next step in the
    # application or back to the confirmation page

    # We need to determine whether the user arrived at the page as part of the
    # application process, or by choosing to edit their details on the
    # confirmation page. Determining this is based on whether
    # edit_link_business_details exists in the session.

    if session[:edit_link_business_details] == @registration.reg_uuid
      session.delete(:edit_link_business_details)
      go_to = confirmation_path(@registration.reg_uuid)
    else
      go_to = contact_details_path(@registration.reg_uuid)
    end

    redirect_to(go_to)

  end

  # GET /your-registration/:reg_uuid/business-details/edit
  def edit
    new_step_action 'businessdetails'
    return unless @registration
    @address = @registration.registered_address
    session[:edit_link_business_details] = @registration.reg_uuid
    redirect_to confirm_route(@address.addressMode)
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
