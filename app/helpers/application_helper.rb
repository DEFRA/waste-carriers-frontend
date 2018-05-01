module ApplicationHelper

  def session_inactivity_timeout_time
  	if session[:last_seen_at]
      last_seen_at = session[:last_seen_at].to_datetime
      timeout = last_seen_at + Rails.application.config.app_session_inactivity_timeout
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
      rescue NoMethodError => e
        Airbrake.notify(e)
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

  def format_as_date_only(d, blank_if_epoch: false)
    if d.to_i == 0 && blank_if_epoch
      ''
    else
      convert_date(d.to_i).strftime("%d/%m/%Y")
    end
  end

  def format_as_ordinal_date_only(d)
    new_date = convert_date(d.to_i)
    new_date.strftime('%A ' + new_date.mday.ordinalize + ' %B %Y')
  end

  def getDefaultCurrency
    "GBP"
  end

end
