module SubdomainHelper

  def with_subdomain(subdomain)
  	if subdomain == 'www'
      host = Rails.application.config.waste_exemplar_frontend_url
    else
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
