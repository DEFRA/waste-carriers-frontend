class KeyPerson < Ohm::Model

  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attribute :first_name
  attribute :last_name
  attribute :position
  attribute :dob_day
  attribute :dob_month
  attribute :dob_year
  attribute :dob
  attribute :person_type

  VALID_DAY = /\A[0-9]{2}/
  VALID_MONTH = /\A[0-9]{2}/
  VALID_YEAR = /\A[0-9]{4}/

  validates :dob_day, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :dob_month, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :dob_month, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :validate_dob

  def set_attribs(a_hash)
    a_hash.each do |prop_name, prop_value|
      Rails.logger.debug "key: #{prop_name}"
      Rails.logger.debug "val: #{prop_value}"
      self.send("#{prop_name}=",prop_value)
    end
  end

  private

  def convert_dob
    begin
      self.dob = Date.civil(self.dob_year.to_i, self.dob_month.to_i, self.dob_day.to_i)
    rescue ArgumentError
      false
    end
  end

  def validate_dob
    errors.add('Date of birth', 'is invalid.') unless convert_dob
  end

end
