class Payment < Ohm::Model

  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attribute :orderKey
  attribute :amount
  attribute :currency
  attribute :mac_code
  attribute :dateReceived
  attribute :dateEntered
  attribute :registrationReference
  attribute :worldPayPaymentStatus
  attribute :updatedByUser
  attribute :comment
  attribute :paymentType


  # Creates a new Payment object from a payment-formatted hash
  #
  # @param payment_hash [Hash] the payment-formatted hash
  # @return [Payment] the Ohm-derived Payment object.
  class << self
    def init (payment_hash)
      payment = Payment.create

      payment_hash.each do |k, v|
        payment.send("#{k}=",v)
      end
      payment.save
      payment
    end
  end


  # POSTs payment to Java/Dropwizard service
  #
  # @param none
  # @return  [Boolean] true if Post is successful (200), false if not
  def save!(registration_uuid)
    url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{registration_uuid}/payments.json"
    Rails.logger.debug "about to post payment: #{to_json.to_s}"
    commited = true
    begin
      response = RestClient.post url,
        to_json,
        :content_type => :json,
        :accept => :json


      result = JSON.parse(response.body)
      Rails.logger.debug  result.class.to_s
      save
      Rails.logger.debug "Commited payment to service: #{attributes.to_s}"
    rescue => e
      Rails.logger.error e.to_s
      commited = false
    end
    commited
  end



  # returns a JSON Java/DropWizard API compatible representation of the Payment object
  #
  # @param none
  # @return  [String]  the payment object in JSON form
  def to_json
    attributes.to_json
  end


  PAYMENT_TYPES = %w[
    CASH
    CHEQUE
    POSTALORDER
  ]

  PAYMENT_TYPES_FINANCE_BASIC = %w[
    OTHERONLINEPAYMENT
    OTHER
  ]

  PAYMENT_TYPES_NONVISIBLE = %w[
    WORLDPAY
    WRITEOFFSMALL
    WRITEOFFLARGE
  ]

  VALID_CURRENCY_REGEX = /\A[-]?[0-9.]+\z/    # This does not allow for a decimal point and currently works in pence only

  validates :amount, presence: true, format: { with: VALID_CURRENCY_REGEX }
  validate :validate_amount
  validates :dateReceived, presence: true, length: { minimum: 8 }
  validate :validate_dateReceived
  validates :registrationReference, presence: true
  # This concatanates all the PAYMENT_TYPE lists. Ideally the user role should be checked to determine which list the user was given.
  validates :paymentType, presence: true, inclusion: { in: %w[].concat(PAYMENT_TYPES).concat(PAYMENT_TYPES_FINANCE_BASIC).concat(PAYMENT_TYPES_NONVISIBLE), message: I18n.t('errors.messages.invalid_selection') }
  validates :comment, length: { maximum: 250 }

  def self.payment_type_options_for_select
    (PAYMENT_TYPES.collect {|d| [I18n.t('payment_types.'+d), d]})
  end

  def self.payment_type_financeBasic_options_for_select
    (PAYMENT_TYPES_FINANCE_BASIC.collect {|d| [I18n.t('payment_types.'+d), d]})
  end

  # Represents the minimum balance needed for a finance basic user to make a write off
  def self.basicMinimum
    0
  end

  # Represents the maximum balance needed for a finance basic user to make a write off
  def self.basicMaximum
    100
  end

  # Represents the maximum balance needed for a finance admin user to make a write off
  def self.adminMaximum
    200
  end

  # Returns true if balance is in range for a small write off, otherwise returns an
  # error message representing why it failed.
  def self.isSmallWriteOff(balance)
    Rails.logger.info 'balance: ' + balance.to_s
    if balance <= Payment.basicMinimum
      Rails.logger.info 'Balance is paid or overpaid'
      I18n.t('payment.newWriteOff.writeOffNotApplicable')
    elsif balance > Payment.basicMaximum
      Rails.logger.info 'Balance is too great'
      I18n.t('payment.newWriteOff.writeOffUnavailable')
    else
      true
    end
  end

  # Returns true if balance is in range for a large write off, otherwise returns an
  # error message representing why it failed.
  def self.isLargeWriteOff(balance)
    Rails.logger.info 'balance: ' + balance.to_s
    if balance <= Payment.basicMaximum
      Rails.logger.info 'Balance is in range for a finance basic user'
      I18n.t('payment.newWriteOff.writeOffNotApplicable')
    elsif balance > Payment.adminMaximum
      Rails.logger.info 'Balance is too great for even a finance admin'
      I18n.t('payment.newWriteOff.writeOffNotAvailable')
    else
      true
    end
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
    if (!PAYMENT_TYPES_NONVISIBLE.include? paymentType)
      errors.add(:dateReceived, I18n.t('errors.messages.invalid') ) unless convert_dateReceived
    end
  end

end
