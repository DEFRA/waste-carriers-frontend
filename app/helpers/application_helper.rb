module ApplicationHelper

  def session_inactivity_timeout_time
  	if session[:last_seen_at]
  	  timeout = session[:last_seen_at] + Rails.application.config.app_session_inactivity_timeout
  	  timeout
  	end
  end
  
  def createTitle(pageTitle)
    t(pageTitle) + " - " + t('registrations.form.root_site')
  end
  
  def convert_date d
    res = Time.new(1970,1,1)
    if d
      begin
        res = Time.at(d / 1000.0)
        # if d is String the NoMethodError will be raised
      rescue NoMethodError
        res = Time.parse(d)
      end
    end #if
    res
  end
  
  def format_time d
    convert_date(d.to_i).strftime("%d/%m/%Y")
  end

end
