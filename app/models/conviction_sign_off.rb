class ConvictionSignOff < Ohm::Model

  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attribute :confirmed
  attribute :confirmedAt
  attribute :confirmedBy

  # returns a hash representation of the ConvictionSignOff object
  #
  # @param none
  # @return  [Hash]  the ConvictionSignOff object as a hash
  def to_hash
    self.attributes.to_hash
  end

  # returns a JSON Java/DropWizard API compatible representation of the ConvictionSignOff object
  #
  # @param none
  # @return  [String]  the ConvictionSignOff object in JSON form
  def to_json
    to_hash.to_json
  end

  def add(a_hash)
    a_hash.each do |prop_name, prop_value|
      self.send(:update, {prop_name.to_sym => prop_value})
    end
  end

  class << self
    def init (conviction_sign_off_hash)
      conviction_sign_off = ConvictionSignOff.create
      conviction_sign_off.update_attributes(conviction_sign_off_hash)
      conviction_sign_off.save
      conviction_sign_off
    end
  end

end
