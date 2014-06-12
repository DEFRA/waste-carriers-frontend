class CompaniesHouseCaller
  attr_reader :url

  def initialize companies_house_registration_number
    @url = "http://data.companieshouse.gov.uk/doc/company/#{companies_house_registration_number}.json"
  end
end