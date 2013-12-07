require 'active_resource'

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :validate_session_total_timeout!
  before_filter :validate_session_inactivity_timeout!

  include ApplicationHelper

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
    session[:expires_at] = Time.current + Rails.application.config.app_session_total_timeout
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

  def is_local_request?
    'localhost' == request.host_with_port[0..8]
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

  #Total session timeout. No session is allowed to be longer than this.
  def validate_session_total_timeout!
    session[:expires_at] ||= Time.current + Rails.application.config.app_session_total_timeout
    if session[:expires_at] < Time.current
      reset_session
      render :file => "/public/session_expired.html", :status => 400    
    end
  end

  #Session inactivity timeout.
  def validate_session_inactivity_timeout!
    if !agency_user_signed_in?
      if session[:last_seen_at] != nil && session_inactivity_timeout_time < Time.current
        reset_session
        render :file => "/public/session_expired.html", :status => 400    
      end
    end
    session[:last_seen_at] = Time.current
  end


  rescue_from CanCan::AccessDenied do |exception| 
    renderAccessDenied
  end

  rescue_from ActiveResource::ResourceNotFound do |exception|
    renderNotFound   
  end  

end
