# Represents an alpha version of a registration record. Only to be used for
# testing.
class PhaseOneRegistration
  include Mongoid::Document

  field :uuid, type: String
  field :businessType, type: String
  field :companyName, type: String
  field :streetLine1, type: String
  field :streetLine2, type: String
  field :townCity, type: String
  field :postcode, type: String
  field :easting, type: String
  field :northing, type: String
  field :dependentLocality, type: String
  field :dependentThroughfare, type: String
  field :administrativeArea, type: String
  field :localAuthorityUpdateDate, type: String
  field :royalMailUpdateDate, type: String
  field :uprn, type: String
  field :title, type: String
  field :otherTitle, type: String
  field :firstName, type: String
  field :lastName, type: String
  field :position, type: String
  field :phoneNumber, type: String
  field :contactEmail, type: String
  field :accountEmail, type: String
  field :declaration, type: String
  field :regIdentifier, type: String

  embeds_one :phase_one_registration_info, store_as: 'metaData'
  embeds_one :phase_one_location, store_as: 'location'

  store_in collection: 'registrations'
end
