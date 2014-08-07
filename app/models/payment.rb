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
  attribute :dateReceived_year
  attribute :dateReceived_month
  attribute :dateReceived_day
  attribute :registrationReference
  attribute :worldPayPaymentStatus
  attribute :updatedByUser
  attribute :comment
  attribute :paymentType
  attribute :manualPayment

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

  def to_hash
    self.attributes.to_hash
  end

  def to_json
    to_hash.to_json
  end


  # POSTs payment to Java/Dropwizard service
  #
  # @param none
  # @return  [Boolean] true if Post is successful (200), false if not
  def save!(registration_uuid)
    raise ArgumentError, 'Registration uuid cannot be nil' unless registration_uuid
    url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{registration_uuid}/payments.json"
    if isManualPayment?
      multiplyAmount #pounds to pennies
    end
    Rails.logger.debug "about to post payment: #{to_json.to_s}"
    commited = true
    begin
      response = RestClient.post url,
        to_json,
        :content_type => :json,
        :accept => :json


      result = JSON.parse(response.body)

      save
      Rails.logger.debug "Commited payment to service: #{attributes.to_s}"
    rescue => e
      Rails.logger.error e.to_s
      commited = false
    end
    if isManualPayment?
      divideAmount #pennies to pounds
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
    BANKTRANSFER
    REVERSAL
  ]

  PAYMENT_TYPES_NONVISIBLE = %w[
    WORLDPAY
    WRITEOFFSMALL
    WRITEOFFLARGE
    REFUND
  ]


  VALID_CURRENCY_POUNDS_REGEX = /\A[-]?([0]|[1-9]+[0-9]*)(\.[0-9]{1,2})?\z/          # This is an expression for formatting currency as pounds
  VALID_CURRENCY_PENCE_REGEX = /\A[-]?[0-9]+\z/                                      # This is an expression for formatting currency as pence

  validates :amount, presence: true, format: { with: VALID_CURRENCY_POUNDS_REGEX }, :if => :isManualPayment?
  validates :amount, presence: true, format: { with: VALID_CURRENCY_PENCE_REGEX },  :if => :isAutomatedPayment?
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
    -500
  end

  # Represents the maximum balance needed for a finance basic user to make a write off
  def self.basicMaximum
    500
  end

  # Represents the maximum balance needed for a finance admin user to make a write off
  def self.adminMaximum
    10000000000
  end

  # Returns true if balance is in range for a small write off, otherwise returns an
  # error message representing why it failed.
  def self.isSmallWriteOff(balance)
    Rails.logger.info 'balance: ' + balance.to_s
    if balance.to_f <= Payment.basicMinimum
      Rails.logger.info 'Balance is paid or overpaid'
      I18n.t('payment.newWriteOff.writeOffNotApplicable')
    elsif balance.to_f > Payment.basicMaximum
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
    if balance.to_f > Payment.adminMaximum
      Rails.logger.info 'Balance is too great for even a finance admin'
      I18n.t('payment.newWriteOff.writeOffNotAvailable')
    else
      true
    end
  end

  class << self
    def find_by_registration(registration_uuid)

      result = registrations = []
      url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{registration_uuid}/payments/new.json"
      begin
        response = RestClient.get url
        if response.code == 200
          result = JSON.parse(response.body) #result should be Hash
          payment =  Payment.init(result)
        else
          Rails.logger.error "Payment.find_by_registration for #{registration_uuid} failed with a #{response.code} response from server"
        end
      rescue => e
        Rails.logger.error e.to_s
      end
      payment

    end
  end
  # Returns the payment from the registration matching the orderCode
  def self.getPayment(registration, orderCode)
    foundPayment = nil
    registration.finance_details.first.payments.each do |payment|
      Rails.logger.info 'Payment getPayment ' + payment.orderKey.to_s
      if orderCode == payment.orderKey
        Rails.logger.info 'Payment getPayment foundPayment'
        foundPayment = payment
      end
    end
    foundPayment
  end

  def isManualPayment?
    self.manualPayment
  end

  def isAutomatedPayment?
    !isManualPayment?
  end
  
  def makeRefund
    self.orderKey = self.orderKey + '_REFUND'
  end
  
  # Ensures if a reversal payment type is selected, then the amount entered is negated
  def negateAmount
    if self.paymentType == "REVERSAL"
      self.amount = -self.amount.to_f.abs
    end
  end

  private

  # This multiplies the amount up from pounds to pence
  def multiplyAmount
    self.amount = (Float(self.amount)*100).to_i
    Rails.logger.info 'multiplyAmount result:' + self.amount.to_s
  end

  # This divides the amount down from pence back to pounds
  def divideAmount
    self.amount = (Float(self.amount)/100).to_s
    Rails.logger.info 'divideAmount result:' + self.amount.to_s
  end

  # Converts the three data input fields from a manual payment into an overal date
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
