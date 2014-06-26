require 'active_resource'

class Director
  include ActiveModel::Model

  attr_accessor :first_name, :last_name, :dob_day, :dob_month, :dob_year
  attr_writer :current_step

  VALID_DAY = /\A[0-9]{2}/
  VALID_MONTH = /\A[0-9]{2}/
  VALID_YEAR = /\A[0-9]{4}/

  validates :dob_day, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :dob_month, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :dob_month, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

end