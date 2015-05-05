class Location < Ohm::Model

  attribute :lat
  attribute :lon

  # Creates a new Metadata object from a metadata-formatted hash
  #
  # @param md_hash [Hash] the metadata-formatted hash
  # @return [Location] the Ohm-derived Location object.
  class << self
    def init (location_hash)
      loc = Location.create
      loc.update_attributes(location_hash)
      loc.save
      loc
    end
  end

end
