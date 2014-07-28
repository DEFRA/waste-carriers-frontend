
class ApplicationController < ActionController::Base
  layout "govuk_template"

  protect_from_forgery

  before_action :set_i18n_locale_from_params

  before_filter :validate_session_total_timeout!
  before_filter :validate_session_inactivity_timeout!

  before_filter :require_admin_url, if: :devise_controller?

  before_filter :set_no_cache


  include ApplicationHelper

  def set_i18n_locale_from_params
    if params[:locale]
      if I18n.available_locales.map(&:to_s).include?(params[:locale])
        I18n.locale = params[:locale]
        logger.debug "locale set to: #{params[:locale]}"
      else
        flash.now[:notice] = "#{params[:locale]} translation not available"
        logger.error flash.now[:notice]
      end
    end
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def after_sign_out_path_for(resource_or_scope)
  	logger.info 'Signout function'
    #request.referrer
    #registrations_path
    #root_path
    #Rails.cache.clear # Could possibly clear the cache here
    reset_session
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
    if user_signed_in? || agency_user_signed_in? || admin_signed_in?
      session[:expires_at] ||= Time.current + Rails.application.config.app_session_total_timeout
      if session[:expires_at] < Time.current
        reset_session
        render :file => "/public/session_expired.html", :status => 400
      end
    end 
  end

  #Session inactivity timeout.
  #Note: There is no inactivity timeout for agency users due to expected work patterns
  def validate_session_inactivity_timeout!
    if user_signed_in? || admin_signed_in?
      if session[:last_seen_at] != nil && session_inactivity_timeout_time < Time.current
        reset_session
        render :file => "/public/session_expired.html", :status => 400
      end
    end
    session[:last_seen_at] = Time.current
  end

  def require_admin_url
    if Rails.application.config.require_admin_requests && !is_admin_request? && request.fullpath[0..5] != '/users'
      #renderAccessDenied
      renderNotFound
    end
  end

  def set_no_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end


  rescue_from CanCan::AccessDenied do |exception|
    renderAccessDenied
  end


  rescue_from Errno::ECONNREFUSED do |exception|
    render :file => "/public/503.html", :status => 503
  end

end
