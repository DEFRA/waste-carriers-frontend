# Represents an address either selected or entered manually by a user which is
# then held against the registration
class Address < Ohm::Model
  attribute :uprn
  attribute :address_mode
  attribute :house_number
  attribute :address_line_1
  attribute :address_line_2
  attribute :address_line_3
  attribute :address_line_4
  attribute :town_city
  attribute :postcode
  attribute :country
  attribute :easting
  attribute :northing
  attribute :dependentLocality
  attribute :dependentThroughfare
  attribute :administrativeArea
  attribute :localAuthorityUpdateDate
  attribute :royalMailUpdateDate

  class << self
    def init(address_hash)
      address = Address.create

      address_hash.each do |k, v|
        address.send(:update, k.to_sym => v)
      end

      address.save
      address
    end

    def from_address_search_result(result)
      address = Address.new

      address.uprn = result.uprn
      address.town_city = result.town
      address.postcode = result.postcode
      address.country = result.country
      address.easting = result.easting
      address.northing = result.northing
      address.dependentLocality = result.dependentLocality
      address.dependentThroughfare = result.dependentThroughfare
      address.administrativeArea = result.administrativeArea
      address.localAuthorityUpdateDate = result.localAuthorityUpdateDate
      address.royalMailUpdateDate = result.royalMailUpdateDate

      address_lines(address, result.lines)
      address
    end

    private

    def address_lines(address, lines)
      return if lines.empty?

      address.address_line_1 = lines[0] unless lines[0].blank?
      address.address_line_2 = lines[0] unless lines[1].blank?
      address.address_line_3 = lines[0] unless lines[2].blank?
      address.address_line_4 = lines[0] unless lines[3].blank?
    end
  end

  # Returns a hash representation of the Address object.
  # @param none
  # @return  [Hash]  the Address object as a hash
  def to_hash
    attributes.to_hash
  end

  # Returns a JSON Java/DropWizard API compatible representation of the
  # Address object.
  # @param none
  # @return  [String]  the Address object in JSON form
  def to_json
    to_hash.to_json
  end
end
