# Represents an alpha version of a location sub record. Only to be used for
# testing.
class PhaseOneLocation
  include Mongoid::Document

  field :lat, type: Float
  field :lon, type: Float

  embedded_in :phase_one_registration
end
