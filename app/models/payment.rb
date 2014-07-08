require 'active_resource'

class Payment < ActiveResource::Base

  #The services URL can be configured in config/application.rb and/or in the config/environments/*.rb files.
  self.site = Rails.configuration.waste_exemplar_services_url
  self.format = :json
  self.prefix = "/registrations/:id/"	# Overrides default prefix url or /payments/<id>
#  self.collection_name = "payment"		# Overrides default collection name of 'payments'
  
  PAYMENT_TYPES = %w[
    CASH
    CHEQUE
    POSTALORDER
    OTHERONLINEPAYMENT
    OTHER
    WORLDPAY
  ]
  
  VALID_CURRENCY_REGEX = /\A[-]?[0-9.]+\z/ 		# This does not allow for a decimal point and currently works in pence only
  
  validates :amount, presence: true, format: { with: VALID_CURRENCY_REGEX }
  validate :validate_amount
  validates :dateReceived, presence: true, length: { minimum: 8 }
  validate :validate_dateReceived
  validates :registrationReference, presence: true
  validates :paymentType, presence: true, inclusion: { in: PAYMENT_TYPES }
  validates :comment, presence: true, length: { maximum: 250 }
  
  def self.payment_type_options_for_select
    (PAYMENT_TYPES.collect {|d| [I18n.t('payment_types.'+d), d]})
  end
  
  private
  
  def validate_amount
    if self.amount.include? "."
      errors.add(:amount, I18n.t('errors.messages.invalid')+ '. This is currently a Defect, Workaround, enter a value in pence only!' )
    end
  end

  def convert_dateReceived
    begin
      self.dateReceived = Date.civil(self.dateReceived_year.to_i, self.dateReceived_month.to_i, self.dateReceived_day.to_i)
    rescue ArgumentError
      false
    end
  end

  def validate_dateReceived
    if (paymentType != 'WORLDPAY')
      errors.add(:dateReceived, I18n.t('errors.messages.invalid') ) unless convert_dateReceived
    end
  end
  
end
