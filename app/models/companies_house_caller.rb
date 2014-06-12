class CompaniesHouseCaller
  attr_reader :url

  def initialize companies_house_registration_number
    @url = "http://data.companieshouse.gov.uk/doc/company/#{pad_with_zeroes_to_make_it_eight_characters companies_house_registration_number}.json"
  end

private

  def pad_with_zeroes_to_make_it_eight_characters companies_house_registration_number
    companies_house_registration_number.rjust(8, '0')
  end
end