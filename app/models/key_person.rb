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

  validates :first_name, :last_name, :dob_day, :dob_month, :dob_year, presence: true

  validates :dob_day, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :dob_month, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :dob_month, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :validate_dob

  class << self
    def init (key_person_hash)
      keyPerson = KeyPerson.create
      key_person_hash.each do |k, v|
        keyPerson.send(:update, {k.to_sym => v})
      end
      keyPerson.save
      keyPerson
    end
  end

  # returns a hash representation of the KeyPerson object
  #
  # @param none
  # @return  [Hash]  the KeyPerson object as a hash
  def to_hash
    self.attributes.to_hash
  end

  # returns a JSON Java/DropWizard API compatible representation of the KeyPerson object
  #
  # @param none
  # @return  [String]  the KeyPerson object in JSON form
  def to_json
    to_hash.to_json
  end

  def add(a_hash)
    a_hash.each do |prop_name, prop_value|
      self.send("#{prop_name}=",prop_value)
    end
  end

  def validate_dob
    set_dob
    errors.add(:dob, I18n.t('errors.messages.invalid_date')) unless dob
    errors.add(:dob, I18n.t('errors.messages.date_not_in_past')) unless dob.try(:past?)
  end

  def set_dob
    begin
      self.dob = Date.civil(self.dob_year.to_i, self.dob_month.to_i, self.dob_day.to_i)
    rescue ArgumentError
      nil
    end
  end

  private :validate_dob

end
