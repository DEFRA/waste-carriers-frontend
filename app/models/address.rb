# Represents an address either selected or entered manually by a user which is
# then held against the registration
class Address < Ohm::Model
  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attribute :uprn
  attribute :address_mode
  attribute :address_type
  attribute :house_number
  attribute :address_line_1
  attribute :address_line_2
  attribute :address_line_3
  attribute :address_line_4
  attribute :town_city
  attribute :postcode
  attribute :country
  attribute :dependent_locality
  attribute :dependent_thoroughfare
  attribute :administrative_area
  attribute :local_authority_update_date
  attribute :royal_mail_update_date

  set :location, :Location # will always be size=1

  ADDRESS_TYPES = %w[
    (REGISTERED)
    (POSTAL)
  ]

  def self.init(address_hash)
    address = Address.create

    address_hash.each do |k, v|
      case k
      when 'location'
        address.location.add Location.init(v)
      else
        address.send(:update, k.to_sym => v)
      end
    end

    address.save
    address
  end

  def self.from_address_search_result(result)
    address = Address.create

    address.uprn = result.uprn
    address.town_city = result.town
    address.postcode = result.postcode
    address.country = result.country

    address.location.add Location.init(easting: result.easting, northing: result.northing)

    address.dependent_locality = result.dependentLocality
    address.dependent_thoroughfare = result.dependentThroughfare
    address.administrative_area = result.administrativeArea
    address.local_authority_update_date = result.localAuthorityUpdateDate
    address.royal_mail_update_date = result.royalMailUpdateDate

    address_lines(address, result.lines)
    address.save
    address
  end

  # Returns a hash representation of the Address object.
  # @param none
  # @return  [Hash]  the Address object as a hash
  def to_hash
    hash = attributes.to_hash

    hash['location'] = location.first.to_hash if location.size == 1
    hash
  end

  # Returns a JSON Java/DropWizard API compatible representation of the
  # Address object.
  # @param none
  # @return  [String]  the Address object in JSON form
  def to_json
    to_hash.to_json
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
