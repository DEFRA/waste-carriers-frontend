class KeyPerson < Ohm::Model


  # N.B: order of includes is important
  include ActiveModel::Conversion
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  extend ActiveModel::Naming
  include ActiveModel::Validations::Callbacks



  attribute :first_name
  attribute :last_name
  attribute :position
  attribute :dob_day
  attribute :dob_month
  attribute :dob_year
  attribute :dob
  attribute :person_type

  set :conviction_search_result, :ConvictionSearchResult #will always be size=1

  VALID_DAY = /\A[0-9]{2}/
  VALID_MONTH = /\A[0-9]{2}/
  VALID_YEAR = /\A[0-9]{4}/

  before_validation :strip_whitespace, :only => [:dob_day, :dob_month, :dob_year]

  validates :first_name, :last_name, :dob_day, :dob_month, :dob_year, presence: true

  validates :dob_day, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :dob_month, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :dob_year, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  validate :validate_dob

  class << self
    def init (key_person_hash)

      key_person = KeyPerson.create

      key_person_hash.each do |k, v|

        case k
        when 'dob', 'dateOfBirth'
          dob = ApplicationController.helpers.convert_date v
          key_person.send(:update, {k.to_sym => v})
          key_person.send(:update, {:dob_day => dob.day})
          key_person.send(:update, {:dob_month => dob.month})
          key_person.send(:update, {:dob_year => dob.year})
        when 'conviction_search_result'
          key_person.conviction_search_result.add ConvictionSearchResult.init(v)
        else
          key_person.send(:update, {k.to_sym => v})
        end
      end

      key_person.save
      key_person

    end

  end

  # returns a hash representation of the KeyPerson object
  #
  # @param none
  # @return  [Hash]  the KeyPerson object as a hash
  def to_hash
    hash = self.attributes.to_hash

    # Perform a length comparison to determine if the to_i function has changed the value.
    # It would do this is the self.dob was a value of 1970-04-93, but would not if it was a long int
    if self.dob.to_i.to_s.length.eql? self.dob.length
      # lengths match thus should be integer, thus convert it to a date
      Rails.logger.debug "Convert " + self.dob.to_i.to_s + " to a Date object"
      hash['dob'] = ApplicationController.helpers.convert_date(self.dob.to_i).to_date
    else
      Rails.logger.debug "Use original value as its already formatted as a Date"
      hash['dob'] = self.dob.to_s
    end

    hash['conviction_search_result'] = conviction_search_result.first.to_hash if conviction_search_result.size == 1
    hash
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
      self.send(:update, {prop_name.to_sym => prop_value})
    end
  end

  def cross_check_convictions

    result = ConvictionSearchResult.search_convictions(name: "#{first_name} #{last_name}", dateOfBirth: dob)
    Rails.logger.debug "KEY_PERSON::CROSS_CHECK_CONVICTIONS #{result}"
    conviction_search_result.replace([result])

  end

  private

  def validate_dob
    set_dob
    errors.add(:dob, I18n.t('errors.messages.invalid_date')) unless dob
    errors.add(:dob, I18n.t('errors.messages.date_not_in_past')) unless dob.try(:past?)
    errors.add(:dob, I18n.t('errors.messages.dob_less_than_18_years')) if dob.try(:>, Date.today-18.years)
  end

  def set_dob
    begin
      resultDate = Date.civil(self.dob_year.to_i, self.dob_month.to_i, self.dob_day.to_i)
      Rails.logger.debug "Calculated DOB of " + resultDate.to_s
      self.dob = resultDate
    rescue ArgumentError
      nil
    end
  end

  def strip_whitespace
    self.dob_day = self.dob_day.strip  unless self.dob_day.blank?
    self.dob_month = self.dob_month.strip unless self.dob_month.blank?
    self.dob_year = self.dob_year.strip unless self.dob_year.blank?
  end

end
