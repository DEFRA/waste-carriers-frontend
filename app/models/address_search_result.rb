# Represents an address returned by the Address lookup service.
class AddressSearchResult
  include ActiveModel::Model

  attr_accessor :moniker
  attr_accessor :uprn
  attr_accessor :postcode
  attr_accessor :partial
  attr_accessor :lines
  attr_accessor :town
  attr_accessor :postcode
  attr_accessor :easting
  attr_accessor :northing
  attr_accessor :country
  attr_accessor :dependentLocality
  attr_accessor :dependentThroughfare
  attr_accessor :administrativeArea
  attr_accessor :localAuthorityUpdateDate
  attr_accessor :royalMailUpdateDate
  attr_accessor :partial
  attr_accessor :subBuildingName
  attr_accessor :buildingName
  attr_accessor :thoroughfareName
  attr_accessor :organisationName
  attr_accessor :buildingNumber
  attr_accessor :postOfficeBoxNumber
  attr_accessor :departmentName
  attr_accessor :doubleDependentLocality

  def self.search(value)
    fail if value.blank?
    results = []

    do_search(
      format(
        '%s/addresses.json',
        Rails.configuration.waste_exemplar_addresses_url
      ),
      postcode: value
    ).each { | r | results << AddressSearchResult.new(r) }

    results
  end

  def self.search_by_id(value)
    fail if value.blank?

    result = do_search(
      format(
        '%s/addresses/%s.json',
        Rails.configuration.waste_exemplar_addresses_url,
        value
      ),
      nil
    )
    AddressSearchResult.new(result)
  end

  def self.do_search(url, params)
    begin
      result = JSON.parse(RestClient.get(url, params: params))
    rescue => e
      Rails.logger.debug e
      result = []
    end
    result
  end
end
