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

      location_hash.each do |k, v|
          loc.send(:update, {k.to_sym => v})
      end

      loc.save
      loc
    end
  end


end
