class CompaniesHouseCaller
  attr_reader :url

  @@COMPANIES_HOUSE_URL = 'http://data.companieshouse.gov.uk/doc/company/'

  def initialize companies_house_registration_number
    @url = "#{@@COMPANIES_HOUSE_URL}#{pad_with_zeroes_to_make_it_eight_characters companies_house_registration_number}.json"
  end

  def active?
    begin
      json = JSON.parse RestClient.get @url
      company_status = json['primaryTopic']['CompanyStatus']
      company_status == 'Active'
    rescue
      false
    end
  end

private

  def pad_with_zeroes_to_make_it_eight_characters companies_house_registration_number
    companies_house_registration_number.try(:rjust, 8, '0')
  end
end