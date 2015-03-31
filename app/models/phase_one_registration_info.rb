# Represents an alpha version of a meta data sub record. Only to be used for
# testing.
class PhaseOneRegistrationInfo
  include Mongoid::Document

  field :dateRegistered, type: String
  field :anotherString, type: String
  field :lastModified, type: String
  field :dateActivated, type: String
  field :status, type: String
  field :route, type: String
  field :distance, type: String

  embedded_in :phase_one_registration
end
