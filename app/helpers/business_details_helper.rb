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
end
