require 'active_resource'

class Order < ActiveResource::Base

  #The services URL can be configured in config/application.rb and/or in the config/environments/*.rb files.
  self.site = Rails.configuration.waste_exemplar_services_url
  self.format = :json
  self.prefix = "/registrations/:id/"	# Overrides default prefix url or /orders/<id>
#  self.collection_name = "order"		# Overrides default collection name of 'orders'

  WORLDPAY_STATUS = %w[
    PENDING
    ACTIVE
    ETC
  ]
  
  VALID_CURRENCY_REGEX = /\A[-]?[0-9.]+\z/ 		# This does not allow for a decimal point and currently works in pence only
  
  validates :orderCode, presence: true
  validates :merchantId, presence: true
  validates :totalAmount, presence: true, format: { with: VALID_CURRENCY_REGEX }
  validate :validate_totalAmount
  validates :currency, presence: true
  validates :dateCreated, presence: true, length: { minimum: 8 }
  validates :worldPayStatus, presence: true, inclusion: { in: WORLDPAY_STATUS }
  validates :dateLastUpdated, presence: true, length: { minimum: 8 }
  validate :validate_dateLastUpdated
  validates :updatedByUser, presence: true
  validates :description, presence: true, length: { maximum: 250 }
  
  def self.worldpay_status_options_for_select
    (WORLDPAY_STATUS.collect {|d| [I18n.t('worldpay_status.'+d), d]})
  end
  
  private
  
  def validate_totalAmount
    if self.totalAmount.include? "."
      errors.add(:totalAmount, I18n.t('errors.messages.invalid')+ '. This is currently a Defect, Workaround, enter a value in pence only!' )
    end
  end

  def convert_dateLastUpdated
    begin
      if self.respond_to?('dateLastUpdated_year') and self.respond_to?('dateLastUpdated_month') and self.respond_to?('dateLastUpdated_day')
        Rails.logger.info 'year FOUND'
        self.dateLastUpdated = Date.civil(self.dateLastUpdated_year.to_i, self.dateLastUpdated_month.to_i, self.dateLastUpdated_day.to_i)
        Rails.logger.info 'dateReceived:' + self.dateReceived
      else
        Rails.logger.info 'year not FOUND'
      end
    rescue ArgumentError
      false
    end
  end

  def validate_dateLastUpdated
    errors.add(:dateLastUpdated, I18n.t('errors.messages.invalid') ) unless convert_dateLastUpdated
  end
  
end
