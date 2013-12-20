module SubdomainHelper

  def with_subdomain(subdomain)
  	#puts "GGG - entering with_subdomain: subdomain = " + subdomain
    if subdomain == 'www'
      #host = Rails.application.config.action_mailer.default_url_options[:host]
      #puts "GGG - subdomain == www. host = " + Rails.application.config.waste_exemplar_frontend_url
      host = Rails.application.config.waste_exemplar_frontend_url
    else
      #puts "GGG - subdomain != www. host = " + Rails.application.config.waste_exemplar_frontend_admin_url
      host = Rails.application.config.waste_exemplar_frontend_admin_url
    end
    host
  end

  def url_for(options = nil)
    if options.kind_of?(Hash) && options.has_key?(:subdomain)
      options[:host] = with_subdomain(options.delete(:subdomain))
    end
    super
  end

end
