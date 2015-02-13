module ApplicationHelper

  def session_inactivity_timeout_time
  	if session[:last_seen_at]
  	  timeout = session[:last_seen_at] + Rails.application.config.app_session_inactivity_timeout
  	  timeout
  	end
  end

  def createTitle(pageTitle)
    "#{t(pageTitle)} - #{t('registrations.form.root_site')}"
  end

  def convert_date(d)
    res = Time.new(1970,1,1)
    if d
      begin
        res = Time.at(d / 1000.0)
        # if d is String the NoMethodError will be raised
      rescue NoMethodError
        res = Time.parse(d)
      end
    end
    res
  end

  def get_expires_in_as_int
    expires_date = Time.at(Rails.configuration.registration_expires_after).to_date
    epoch_date = Date.new(1970, 1, 1)

    (expires_date - epoch_date).to_i / 365
  end

  def format_time(d)
    convert_date(d.to_i).strftime("%d/%m/%Y %H:%M")
  end

  def format_as_date_only(d)
    convert_date(d.to_i).strftime("%d/%m/%Y")
  end

  def format_as_ordinal_date_only(d)
    new_date = convert_date(d.to_i)
    new_date.strftime('%A ' + new_date.mday.ordinalize + ' %B %Y')
  end

  def getDefaultCurrency
    "GBP"
  end

  # Sets a flag in the session based on the current user type.  Called after a user signs in.
  # This flag is used by other methods in RegistrationsHelper, and will be removed automatically
  # when a user logs-out because the session is reset at that point.
  def set_google_analytics_user_type_indicator(session)
    session[:ga_user_type] = 'newUser'
    if user_signed_in?
      session[:ga_user_type] = 'existingUser'
    elsif agency_user_signed_in?
      session[:ga_user_type] = 'agencyUser'
    elsif admin_signed_in?
      session[:ga_user_type] = 'adminUser'
    end
  end
end
