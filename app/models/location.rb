# Holds additional location details for the business address on a registration
class Location < Ohm::Model
  attribute :lat
  attribute :lon

  # Creates a new Location object from a location formatted hash
  #
  # @param location_hash [Hash] the location formatted hash
  # @return [Location] the Ohm-derived Location object.
  class << self
    def init(location_hash)
      loc = Location.create

      location_hash.each do |k, v|
        loc.send(:update, k.to_sym => v)
      end

      loc.save
      loc
    end
  end

  # Returns a hash representation of the Location object.
  # @param none
  # @return  [Hash]  the Location object as a hash
  def to_hash
    self.attributes.to_hash
  end

  # Returns a JSON Java/DropWizard API compatible representation of the
  # Location object.
  # @param none
  # @return  [String]  the Location object in JSON form
  def to_json
    to_hash.to_json
  end
end
