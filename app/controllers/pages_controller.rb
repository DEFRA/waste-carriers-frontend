class PagesController < ApplicationController
  # Controller for pages with static content.
  
  # A page thanking the user for confirming their account.  Users are redirected
  # to this page if their most recent registration was Upper Tier.
  def account_confirmed
  end
  
  # A page that tells the user their password has been changed, and that they
  # should continue with their registration in the previous browser tab.
  def mid_registration_password_changed
  end
end
