
class ApplicationController < ActionController::Base
  layout "govuk_template"

  # If changes are required to the layout template, create a copy of the file from the version on GitHUb
  # and place a copy of the file inside the layouts folder (create it if neccessary, under views)
  # and name it appropriately e.g. govuk_template_v0_10_0 if the file is a copy from the gov.uk template v0.10.0
  #layout "layouts/govuk_template_v0_10_0"

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
        logger.debug flash.now[:notice]
      end
    end
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def after_sign_out_path_for(resource_or_scope)
  	logger.debug 'Signout function'
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
  	  user_registrations_path(resource)
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

  def is_public_request?
    'www' == request.host_with_port[0..2]
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

  def renderSessionExpired
    render :file => "/public/session_expired.html", :status => 401
  end

  def renderNotFound
    render :file => "/public/404.html", :status => 404
  end

  #Total session timeout. No session is allowed to be longer than this.
  def validate_session_total_timeout!
    if user_signed_in? || agency_user_signed_in? || admin_signed_in?
      now = Time.current
      logger.debug 'Validating session total timout. Now it is ' + now.to_s
      session[:expires_at] ||= now + Rails.application.config.app_session_total_timeout
      if session[:expires_at] < now
        reset_session
        render :file => "/public/session_expired.html", :status => 401
      end
    end
  end

  #Session inactivity timeout.
  #Note: There is no inactivity timeout for agency users due to expected work patterns
  def validate_session_inactivity_timeout!
    if user_signed_in? || admin_signed_in?
      now = Time.current
      logger.debug 'Validating session inactivity timeout. Now it is ' + now.to_s
      if session[:last_seen_at]
        logger.debug 'User was last seen at ' + session[:last_seen_at].to_s
      end
      if session[:last_seen_at] != nil && session_inactivity_timeout_time < now
        logger.debug 'The session is deemed to have expired. Showing the Session Expired page.'
        reset_session
        render :file => "/public/session_expired.html", :status => 401
      end
    end
    session[:last_seen_at] = Time.current
  end

  def require_admin_url
    #This is to ensure that the Devise-managed login URLs for agency users and admins are visible
    #and available only via the internal admin URLs
    if Rails.application.config.require_admin_requests && !is_admin_request? && request.fullpath[0..5] != '/users'
      logger.warn "Attempted request to access internal login pages. Returning 404 not found."
      renderNotFound
      return
    end

    #However, when using the internal admin interface, it should not be possible to login as an external waste carrier either.
    if Rails.application.config.require_admin_requests && is_admin_request? && request.fullpath[0..5] == '/users'
      logger.warn "Attempted request to log in as user via admin URL. Returning 404 not found."
      renderNotFound
    end

  end

  def set_no_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def generateOrderCode
    SecureRandom.uuid.split('-').last
  end

  rescue_from CanCan::AccessDenied do |exception|
    notify_airbrake(exception)
    renderAccessDenied
  end

  rescue_from Errno::ECONNREFUSED do |exception|
    notify_airbrake(exception)
    render file: "/public/503.html", status: 503
  end

end
