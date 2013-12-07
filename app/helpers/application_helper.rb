module ApplicationHelper

  def session_inactivity_timeout_time
  	if session[:last_seen_at]
  	  timeout = session[:last_seen_at] + Rails.application.config.app_session_inactivity_timeout
  	  timeout
  	end
  end

end
