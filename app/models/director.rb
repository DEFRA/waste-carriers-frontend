require 'active_resource'

class Director
  include ActiveModel::Model

  attr_accessor :first_name, :last_name, :dob_day, :dob_month, :dob_year, :dob, :temp_id
  attr_writer :current_step

  VALID_DAY = /\A[0-9]{2}/
  VALID_MONTH = /\A[0-9]{2}/
  VALID_YEAR = /\A[0-9]{4}/

  validates :dob_day, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :dob_month, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :dob_month, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :validate_dob

  private

  def convert_dob
    begin
      self.dob = Date.civil(self.dob_year.to_i, self.dob_month.to_i, self.dob_day.to_i)
    rescue ArgumentError
      false
    end
  end

  def validate_dob
    errors.add("Date of birth", "is invaid.") unless convert_dob
  end

end