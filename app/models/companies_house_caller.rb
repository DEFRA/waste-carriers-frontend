class CompaniesHouseCaller
  attr_reader :url

  @@COMPANIES_HOUSE_URL = 'http://data.companieshouse.gov.uk/doc/company/'

  def initialize companies_house_registration_number
    formatted_companies_house_registration_number = format_companies_house_registration_number companies_house_registration_number
    @url = "#{@@COMPANIES_HOUSE_URL}#{formatted_companies_house_registration_number}.json"
  end

  def status
    begin
      json = JSON.parse RestClient.get @url
      company_status = json['primaryTopic']['CompanyStatus']
      company_status == 'Active' ? :active : :inactive
    rescue RestClient::ResourceNotFound
      :not_found
    rescue
      :error_calling_service
    end
  end

private

  def format_companies_house_registration_number companies_house_registration_number
    eight_characters = pad_with_zeroes_to_make_it_eight_characters companies_house_registration_number
    eight_characters.try :upcase
  end

  def pad_with_zeroes_to_make_it_eight_characters companies_house_registration_number
    companies_house_registration_number.try(:rjust, 8, '0')
  end
end