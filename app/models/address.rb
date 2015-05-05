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

  VALID_CHARACTERS = /\A[A-Za-z0-9\s\'\.&!%]*\Z/
  VALID_HOUSE_NAME_OR_NUMBER_REGEX = /\A[a-zA-Z0-9\'\s\,\&-]+\z/
  TOWN_CITY_REGEX = /\A[a-zA-Z0-9\'\s\,-]+\z/
  POSTCODE_CHARACTERS = /\A[A-Za-z0-9\s]*\Z/

  def self.init(address_hash)
    address = Address.create

    address_hash.each do |k, v|
      if k == 'location'
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
    address.populate_from_address_search_result(result)
    address
  end

  def populate_from_address_search_result(result)
    self.uprn = result.uprn
    self.town_city = result.town
    self.postcode = result.postcode
    self.country = result.country

    location.replace([Location.init(
      easting: result.easting,
      northing: result.northing
    )])

    self.dependent_locality = result.dependentLocality
    self.dependent_thoroughfare = result.dependentThroughfare
    self.administrative_area = result.administrativeArea
    self.local_authority_update_date = result.localAuthorityUpdateDate
    self.royal_mail_update_date = result.royalMailUpdateDate

    address_lines(result.lines)
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

  # Validations
  with_options if: :address_lookup? do |address|
    address.validates :houseNumber, presence: true, format: { with: VALID_HOUSE_NAME_OR_NUMBER_REGEX, message: I18n.t('errors.messages.invalid_building_name_or_number_characters') }, length: { maximum: 35 },  unless: :address_lookup_page?
    address.validates :townCity, presence: true, format: { with: TOWN_CITY_REGEX }, unless: :address_lookup_page?
    address.validates :postcode, uk_postcode: true
  end

  with_options if: :manual_uk_address? do |address|
    address.validates :houseNumber, :presence => { :message => I18n.t('errors.messages.blank_building_name_or_number') }, format: { with: VALID_HOUSE_NAME_OR_NUMBER_REGEX, message: I18n.t('errors.messages.invalid_building_name_or_number_characters'), :allow_blank => true }, length: { maximum: 35 }
    address.validates :streetLine1, :presence => { :message => I18n.t('errors.messages.blank_address_line') }, length: { maximum: 35 }
    address.validates :streetLine2, length: { maximum: 35 }
    address.validates :townCity, :presence => { :message => I18n.t('errors.messages.blank_town_or_city') }, format: { with: TOWN_CITY_REGEX, message: I18n.t('errors.messages.invalid_town_or_city'), :allow_blank => true }
    address.validates :postcode, uk_postcode: true
  end

  with_options if: :manual_foreign_address? do |address|
    address.validates :streetLine1, :presence => { :message => I18n.t('errors.messages.blank_address_line') }, length: { maximum: 35 }
    address.validates :streetLine2, :streetLine3, :streetLine4, length: { maximum: 35 }
    address.validates :country, :presence => { :message => I18n.t('errors.messages.blank_country') }, length: { maximum: 35 }
  end

  private

  def address_lines(lines)
    return if lines.empty?

    self.address_line_1 = lines[0] unless lines[0].blank?
    self.address_line_2 = lines[0] unless lines[1].blank?
    self.address_line_3 = lines[0] unless lines[2].blank?
    self.address_line_4 = lines[0] unless lines[3].blank?
  end

  # Validation helpers

  def address_lookup?
    address_mode != 'manual-uk' && address_mode != 'manual-foreign'
  end

  def manual_uk_address?
    address_mode == 'manual-uk'
  end

  def manual_foreign_address?
    address_mode == 'manual-foreign'
  end
end
