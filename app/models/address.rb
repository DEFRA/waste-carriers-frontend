# Represents an address either selected or entered manually by a user which is
# then held against the registration
class Address < Ohm::Model
  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  # We have had to conciously go with using CamelCase rather than the standard
  # snake_case. When we do a public search or the agency does a search we query
  # Elasticsearch via the services, and return directly what we find in
  # Elasticsearch. The problem is that the jackson ObjectMapper seems to set
  # those properties we annotate as being snake case (cause in the POJO they
  # will be snake case) to null. We had no time to resolve this so had to accept
  # the hack of using snake case in the Rails side in order to match with the
  # POJO on the services side.
  attribute :uprn
  attribute :addressType
  attribute :addressMode
  attribute :houseNumber
  attribute :addressLine1
  attribute :addressLine2
  attribute :addressLine3
  attribute :addressLine4
  attribute :townCity
  attribute :postcode
  attribute :country
  attribute :dependentLocality
  attribute :dependentThoroughfare
  attribute :administrativeArea
  attribute :localAuthorityUpdateDate
  attribute :royalMailUpdateDate
  attribute :easting
  attribute :northing
  attribute :firstName
  attribute :lastName

  set :location, :Location # will always be size=1

  ADDRESS_TYPES = %w[
    (REGISTERED)
    (POSTAL)
  ]

  VALID_CHARACTERS = /\A[A-Za-z0-9\s\'\.&!%]*\Z/
  VALID_HOUSE_NAME_OR_NUMBER_REGEX = /\A[a-zA-Z0-9\'\s\,\&-]+\z/
  TOWN_CITY_REGEX = /\A[a-zA-Z0-9\'\s\,-]+\z/
  POSTCODE_CHARACTERS = /\A[A-Za-z0-9\s]*\Z/
  FIRST_NAME_REGEX = /\A[a-zA-Z\s\-\']+\z/
  LAST_NAME_REGEX = /\A[a-zA-Z\s\-\']+\z/

  def self.init(address_hash)
    address = Address.create

    address_hash.each do |k, v|
      if k == 'location'
        address.location.add Location.init(v) unless v.nil?
      else
        address.send(:update, k.to_sym => v)
      end
    end

    address.save
    address
  end

  def self.from_address_search_result(result)
    address = Address.create
    address.populate_from_address_search_result(result)
    address
  end

  def populate_from_address_search_result(result)
    clear

    # We want to retain the fact we are in address-results mode so that
    # whenever the user returns to the business details page the list of
    # addresses should be shown with their's automatically selected. It gets
    # cleared in the call to clear above.
    self.addressMode = 'address-results'
    self.uprn = result.uprn
    self.townCity = result.town
    self.postcode = result.postcode
    self.country = result.country
    self.dependentLocality = result.dependentLocality
    self.dependentThoroughfare = result.dependentThroughfare
    self.administrativeArea = result.administrativeArea
    self.localAuthorityUpdateDate = result.localAuthorityUpdateDate
    self.royalMailUpdateDate = result.royalMailUpdateDate
    self.easting = result.easting
    self.northing = result.northing

    # Protect against sending through a null object
    address_lines(result.lines) if result.lines
    save
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

  def add(a_hash)
    a_hash.each do |prop_name, prop_value|
      self.send(:update, {prop_name.to_sym => prop_value})
    end
  end

  # Will clear all attributes except the addressType. We need this because of
  # the different address modes currently used. Depending on the mode only
  # certain fields will be populated. So to avoid errors if we switch modes we
  # we first clear out the existing data.
  def clear
    arg = {
      uprn: nil,
      addressMode: nil,
      houseNumber: nil,
      addressLine1: nil,
      addressLine2: nil,
      addressLine3: nil,
      addressLine4: nil,
      townCity: nil,
      postcode: nil,
      country: nil,
      dependentLocality: nil,
      dependentThoroughfare: nil,
      administrativeArea: nil,
      localAuthorityUpdateDate: nil,
      royalMailUpdateDate: nil,
      easting: nil,
      northing: nil,
      firstName: nil,
      lastName: nil }
    update_attributes(arg)

    location[0] = nil if location[0]
    save
  end

  def address_results?
    addressMode == 'address-results'
  end

  def address_lookup?
    addressMode != 'manual-uk' && addressMode != 'manual-foreign'
  end

  def manual_uk_address?
    addressMode == 'manual-uk'
  end

  def manual_foreign_address?
    addressMode == 'manual-foreign'
  end

  def postal_address?
    addressType == 'POSTAL'
  end

  def registered_address?
    addressType == 'REGISTERED'
  end

  with_options if: :manual_uk_address? do |address|
    address.validates :houseNumber, presence: { message: I18n.t('errors.messages.blank_building_name_or_number') }, format: { with: VALID_HOUSE_NAME_OR_NUMBER_REGEX, message: I18n.t('errors.messages.invalid_building_name_or_number_characters'), allow_blank: true }, length: { maximum: 35 }
    address.validates :addressLine1, presence: { message: I18n.t('errors.messages.blank_address_line') }, length: { maximum: 35 }
    address.validates :addressLine2, length: { maximum: 35 }
    address.validates :townCity, presence: { message:  I18n.t('errors.messages.blank_town_or_city') }, format: { with: TOWN_CITY_REGEX, message: I18n.t('errors.messages.invalid_town_or_city'), allow_blank: true }
  end

  with_options if: :manual_foreign_address? do |address|
    address.validates :addressLine1, presence: { message: I18n.t('errors.messages.blank_address_line') }, length: { maximum: 35 }
    address.validates :addressLine2, :addressLine3, :addressLine4, length: { maximum: 35 }
    address.validates :townCity, presence: { message:  I18n.t('errors.messages.blank_town_or_city') }, format: { with: TOWN_CITY_REGEX, message: I18n.t('errors.messages.invalid_town_or_city'), allow_blank: true }
    address.validates :country, presence: { message: I18n.t('errors.messages.blank_country') }, length: { maximum: 35 }
  end

  with_options if: :postal_address? do |address|
    address.validates :firstName, presence: { message: I18n.t('errors.messages.blank_first_name') }, format: { with: FIRST_NAME_REGEX, message: I18n.t('errors.messages.invalid_first_name'), allow_blank: true}, length: { maximum: 35 }
    address.validates :lastName, presence: { message: I18n.t('errors.messages.blank_last_name') }, format: { with: LAST_NAME_REGEX, message: I18n.t('errors.messages.invalid_last_name'), allow_blank: true }, length: { maximum: 35 }
    address.validates :addressLine1, presence: { message: I18n.t('errors.messages.blank_address_line') }, length: { maximum: 35 }
  end

  validates :postcode, uk_postcode: true, if: :validate_postcode?

  private

  def validate_postcode?
    result = false
    unless addressType == 'POSTAL'
      result = address_lookup? || manual_uk_address?
    end
    result
  end

  def address_lines(lines)
    return if lines.empty?

    self.houseNumber = lines[0] unless lines[0].blank?
    self.addressLine1 = lines[1] unless lines[0].blank?
    self.addressLine2 = lines[2] unless lines[1].blank?
    self.addressLine3 = lines[3] unless lines[2].blank?
  end
end
