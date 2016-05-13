class CompaniesHouseCaller
  attr_reader :url

  @@COMPANIES_HOUSE_URL = 'http://data.companieshouse.gov.uk/doc/company/'

  def initialize companies_house_registration_number
    formatted_companies_house_registration_number = format_companies_house_registration_number companies_house_registration_number
    @url = "#{@@COMPANIES_HOUSE_URL}#{formatted_companies_house_registration_number}.json"
  end

  def status
    raw_response = ''
    begin
      Rails.logger.debug Time.now.to_s + ' - Calling Companies House...'
      raw_response = RestClient.get(@url)
      json = JSON.parse(raw_response)
      Rails.logger.debug Time.now.to_s + ' - Companies House has returned json response'
      company_status = json['primaryTopic']['CompanyStatus']
      Rails.logger.debug 'Company status is ' + company_status
      company_status == 'Active' ? :active : :inactive
    rescue RestClient::ResourceNotFound
      Rails.logger.debug 'Companies House: Resource not found!'
      :not_found
    rescue => e
      # Handle the new way that Companies House seems to provide a response for
      # 'not found' company numbers.
      raw_response.downcase!()
      if raw_response.include?('resource not found') && raw_response.include?('error code: 9001')
        :not_found
      else
        Airbrake.notify(e)
        Rails.logger.error 'ERROR *** Companies House: Error calling service!!! ' + e.to_s
        :error_calling_service
      end
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
