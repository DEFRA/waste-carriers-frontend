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

  MAX_ALLOWED_AGE = 110.years
  MIN_DIRECTOR_AGE = 16.years
  MIN_NON_DIRECTOR_AGE = 17.years

  FIRST_NAME_REGEX = /\A[a-zA-Z\s\-\']+\z/
  LAST_NAME_REGEX = /\A[a-zA-Z\s\-\']+\z/

  before_validation :strip_whitespace, only: [:dob_day, :dob_month, :dob_year]

  validates :first_name,
    presence: { message: I18n.t('errors.messages.blank_first_name') },
    format: { with: FIRST_NAME_REGEX, message: I18n.t('errors.messages.invalid_first_name'), allow_blank: true},
    length: { maximum: 35 }

  validates :last_name,
    presence: { message: I18n.t('errors.messages.blank_last_name') },
    format: { with: LAST_NAME_REGEX, message: I18n.t('errors.messages.invalid_last_name'), allow_blank: true},
    length: { maximum: 35 }

  validates :position, presence: { message: I18n.t('errors.messages.blank_position') }

  validates :dob_day,
    presence: { message: I18n.t('errors.messages.blank_day') },
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 31,
      message: I18n.t('errors.messages.invalid_day'),
      allow_blank: true
    }

  validates :dob_month,
    presence: { message: I18n.t('errors.messages.blank_month') },
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 12,
      message: I18n.t('errors.messages.invalid_month'),
      allow_blank: true
    }

  validates :dob_year,
    presence: { message: I18n.t('errors.messages.blank_year') },
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 1,
      message: I18n.t('errors.messages.invalid_year'),
      allow_blank: true
    }

  validate :validate_dob

  class << self
    def init (key_person_hash)
      key_person = KeyPerson.create
      normal_attributes = Hash.new

      key_person_hash.each do |k, v|
        case k
        when 'dob', 'dateOfBirth'
          dob = ApplicationController.helpers.convert_date v
          key_person.dob = v
          key_person.dob_day = dob.day
          key_person.dob_month = dob.month
          key_person.dob_year = dob.year
        when 'conviction_search_result'
          key_person.conviction_search_result.add(ConvictionSearchResult.init(v))
        else
          normal_attributes.store(k, v)
        end
      end

      key_person.update_attributes(normal_attributes)

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
      Rails.logger.debug "Convert to a Date object"
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
    result = ConvictionSearchResult.search_person_convictions(
      firstname: first_name,
      lastname:  last_name,
      dateofbirth: dob_elements_as_string()
    )

    conviction_search_result.replace([result])
  end

  def to_long_string
    "#{first_name}#{last_name}#{dob_day}#{dob_month}#{dob_year}"
  end

  private

  def validate_dob
    set_dob

    if no_existing_dob_errors?
      if dob
        if dob.try(:>, Date.today)
          errors.add(:dob, I18n.t('errors.messages.date_not_in_past'))
        elsif dob.try(:<, MAX_ALLOWED_AGE.ago)
          errors.add(:dob, I18n.t('errors.messages.invalid_date'))
        else
          if position == 'Director'
            if dob.try(:>, MIN_DIRECTOR_AGE.ago)
              errors.add(:dob, I18n.t('errors.messages.director_dob_less_than_16_years'))
            end
          else
            if dob.try(:>, MIN_NON_DIRECTOR_AGE.ago)
              errors.add(:dob, I18n.t('errors.messages.non-director_dob_less_than_17_years'))
            end
          end
        end
      else
        errors.add(:dob, I18n.t('errors.messages.invalid_date'))
      end
    end
  end

  def set_dob
    begin
      resultDate = Date.civil(self.dob_year.to_i, self.dob_month.to_i, self.dob_day.to_i)
      Rails.logger.debug "Calculated DOB"
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

  def director?
    self.position == 'Director'
  end

  def no_existing_dob_errors?
    (!self.errors.include? :dob_day) && (!self.errors.include? :dob_month) && (!self.errors.include? :dob_year)
  end

  def dob_elements_as_string
    "%d-%02d-%02d" % [self.dob_year.to_i, self.dob_month.to_i, self.dob_day.to_i]
  end
end
