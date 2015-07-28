# Helper methods used by the various business details pages
module BusinessDetailsHelper
  # We need to determine whether the user arrived at the page as part of the
  # application process, or by choosing to edit their details on the
  # confirmation page. Determining this is based on whether
  # edit_link_business_details exists in the session.
  def redirect_to?
    if session[:edit_link_business_details]
      session.delete(:edit_link_business_details)
      go_to = :newConfirmation
    else
      go_to = :newContact
    end
    go_to
  end

  # Returns where the user should be redirected to based on the address_mode
  # specified. Essentially the default route both when applying or editing
  # the address is business_details. If you are editing your address though
  # and previously set that you were entering it manually, displaying the
  # default address lookup will be of no use. So we call into here to see if
  # you should actually be redirected to one of the other address entry pages.
  # N.B. given the time we would change address entry so that it is just one
  # screen and there is only one mode (single form with address lookup as an
  # aid) which would stop all this nonsense.
  def confirm_route(address_mode)
    if address_mode == 'manual-uk'
      result = business_details_manual_path
    elsif address_mode == 'manual-foreign'
      result = business_details_non_uk_path
    else
      result = business_details_path
    end
  end
end
