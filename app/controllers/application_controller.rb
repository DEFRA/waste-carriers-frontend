require 'active_resource'

class ApplicationController < ActionController::Base
  protect_from_forgery

  def after_sign_out_path_for(resource_or_scope)
  	logger.info 'Signout function'
    #request.referrer
    #registrations_path
    #root_path
    #Rails.cache.clear # Could possibly clear the cache here
    Rails.configuration.waste_exemplar_end_url
  end
  
  def logger
    Rails.logger
  end

  def after_sign_in_path_for(resource)
  	if user_signed_in?
  	  userRegistrations_path(resource)
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

  def current_ability
    @current_ability ||= Ability.new(current_any_user)
  end

  def current_any_user
    current_user || current_agency_user || current_admin
  end

  def renderAccessDenied
    render :file => "/public/403.html", :status => 403 
  end

  def renderNotFound
    render :file => "/public/404.html", :status => 404     
  end

  rescue_from CanCan::AccessDenied do |exception| 
    renderAccessDenied
  end

  rescue_from ActiveResource::ResourceNotFound do |exception|
    renderNotFound   
  end  

end
