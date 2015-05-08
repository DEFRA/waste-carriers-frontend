class Metadata < Ohm::Model

  attribute :status
  attribute :route
  attribute :dateRegistered
  attribute :anotherString
  attribute :lastModified
  attribute :dateActivated
  attribute :revokedReason
  attribute :distance


  # Creates a new Metadata object from a metadata-formatted hash
  #
  # @param md_hash [Hash] the metadata-formatted hash
  # @return [Metadata] the Ohm-derived Metadata object.
  class << self
    def init (md_hash)
      md = Metadata.create
      md.update_attributes(md_hash)
      md.save
      md
    end
  end
end
