class ApplicationController < ActionController::Base
  protect_from_forgery

  def after_sign_out_path_for(resource_or_scope)
    #request.referrer
    registrations_path
  end

  def after_sign_in_path_for(resource)
  	if user_signed_in?
  	  registrations_path
  	elsif agency_user_signed_in?
  	  registrations_path
  	elsif admin_signed_in?
  	  agency_users_path
  	else
      registrations_path
  	end
  end

  def is_admin_request?
    'admin' == request.host_with_port[0..4]
  end

end
