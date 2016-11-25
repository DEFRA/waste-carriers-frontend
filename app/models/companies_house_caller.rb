class CompaniesHouseCaller
  attr_reader :url

  def initialize(companies_house_registration_number)
    @url = URI.join(
      Rails.configuration.waste_exemplar_companies_house_api_url,
      format_companies_house_registration_number(companies_house_registration_number)
    ).to_s
  end

  def status
    raw_response = ''

    begin
      Rails.logger.debug 'Calling Companies House...'
      json = JSON.parse(RestClient::Request.execute({
        method: :get,
        url: @url,
        user: Rails.configuration.waste_exemplar_companies_house_api_key,
        password: ''
      }))
      Rails.logger.debug 'Companies House has returned json response'

      company_status = json['company_status']
      Rails.logger.debug 'JSON company status is ' + company_status
      Rails.configuration.waste_exemplar_allowed_company_statuses.include?(company_status) ? :active : :inactive

    rescue RestClient::ResourceNotFound
      Rails.logger.debug 'Companies House: resource not found'
      :not_found

    rescue => e
      Airbrake.notify(e)
      Rails.logger.error 'Companies House error: ' + e.to_s
      :error_calling_service
    end
  end

private
  def format_companies_house_registration_number companies_house_registration_number
    eight_characters = pad_with_zeroes_to_make_it_eight_characters companies_house_registration_number.try(:strip)
    eight_characters.try :upcase
  end

  def pad_with_zeroes_to_make_it_eight_characters companies_house_registration_number
    companies_house_registration_number.try(:rjust, 8, '0')
  end
end
