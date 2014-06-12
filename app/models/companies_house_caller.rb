class CompaniesHouseCaller
  attr_reader :url

  def initialize companies_house_registration_number
    companies_house_registration_number_padded_with_zeroes_to_eight_characters = companies_house_registration_number.rjust(8, '0')
    @url = "http://data.companieshouse.gov.uk/doc/company/#{companies_house_registration_number_padded_with_zeroes_to_eight_characters}.json"
  end
end