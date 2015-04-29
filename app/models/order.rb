class Order < Ohm::Model

  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attribute :orderId
  attribute :orderCode
  attribute :paymentMethod
  attribute :merchantId
  attribute :totalAmount
  attribute :currency
  attribute :dateCreated
  attribute :worldPayStatus
  attribute :dateLastUpdated
  attribute :updatedByUser
  attribute :description

  # These are meta data fields used only in rails for storing a temporary value to determine:
  # if the amount entered is positive or negative
  attribute :amountType
  # the exception detail from the services
  attribute :exception
  # the type of amount entered, pence or pounds, if manual then pounds used, if not pence are used
  attribute :manualOrder
  
  # This is used to story the order item reference used in charge adjustments, this value is put inside the OrderItem.reference prior to saving
  attribute :order_item_reference

  set :order_items, :OrderItem

  # Creates a new Order object from an order-formatted hash
  # @param order_hash [Hash] the order-formatted hash
  # @return [Order] the Ohm-derived Order object.
  class << self
    def init (order_hash)
      order = Order.create
      normal_attributes = Hash.new

      order_hash.each do |k, v|
        case k
        when 'orderItems'
          if v
            # Important! Need to delete the order_items before new ones are
            # added.
            order.order_items.each do |orderItem|
              order.order_items.delete orderItem
            end

            v.each do |item_hash|
              orderItem = OrderItem.init(item_hash)
              order.order_items.add orderItem
            end
          end #if
        else
          normal_attributes.store(k, v)
        end #case
      end
      
      order.update_attributes(normal_attributes)
      
      order.save
      order
    end
  end


  # Returns a JSON Java/DropWizard API compatible representation of this object.
  # @param none
  # @return  [String]  the order object in JSON form
  def to_json
    to_hash.to_json
  end

  # Returns a hash representation of this object.
  # @param none
  # @return  [Hash]  the order object as a hash
  def to_hash
    h = self.attributes.to_hash
    if self.order_items && self.order_items.size > 0
      h["orderItems"] = order_items.map { |orderItem| orderItem.to_hash }
    end
    h
  end


  # POSTs order to Java/Dropwizard service.
  # @param none
  # @return  [Boolean] true if Post is successful (200), false if not
  def commit (registration_uuid)
    url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{registration_uuid}/orders.json"
    negateAmount
    poundsToPence
    Rails.logger.debug "about to post order: #{to_json.to_s}"
    commited = true
    begin
      response = RestClient.post url,
        to_json,
        :content_type => :json,
        :accept => :json

      result = JSON.parse(response.body)
      Rails.logger.debug  result.class.to_s
      save
      Rails.logger.debug "Commited order to service: #{attributes.to_s}"
    rescue => e
      Rails.logger.error e.to_s

      if e.http_code == 422
        # Get actual error from services
        htmlDoc = Nokogiri::HTML(e.http_body)
        messageFromServices = htmlDoc.at_css("body ul li").content
        Rails.logger.error messageFromServices
        # Update order with a exception message
        self.exception = messageFromServices
      elsif e.http_code == 400
        # Get actual error from services
        htmlDoc = Nokogiri::HTML(e.http_body)
        messageFromServices = htmlDoc.at_css("body pre").content
        Rails.logger.error messageFromServices
        # Update order with a exception message
        self.exception = messageFromServices
      else
        self.exception = e.to_s
      end

      commited = false
    end
    unNegateAmount
    penceToPounds
    commited
  end

  # PUT order to Java/Dropwizard service.
  # @param none
  # @return  [Boolean] true if Post is successful (200), false if not
  def save!(registration_uuid)
    url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{registration_uuid}/orders/#{orderId}.json"
    commited = true
    begin
      response = RestClient.put url,
        to_json,
        :content_type => :json,
        :accept => :json

      result = JSON.parse(response.body)
      Rails.logger.debug  result.class.to_s
      save
    rescue => e
      Rails.logger.error e.to_s
      if e.http_code == 422
        # Get actual error from services
        htmlDoc = Nokogiri::HTML(e.http_body)
        messageFromServices = htmlDoc.at_css("body ul li").content
        Rails.logger.error messageFromServices
        # Update order with a exception message
        self.exception = messageFromServices
      elsif e.http_code == 400
        # Get actual error from services
        htmlDoc = Nokogiri::HTML(e.http_body)
        messageFromServices = htmlDoc.at_css("body pre").content
        Rails.logger.error messageFromServices
        # Update order with a exception message
        self.exception = messageFromServices
      end
      commited = false
    end
    commited
  end

  # Returns the payment from the registration matching the orderCode
  def self.getOrder(registration, orderCode)
    foundOrder = nil
    registration.finance_details.first.orders.each do |order|
      Rails.logger.info 'Payment getOrder ' + order.orderCode.to_s
      if orderCode == order.orderCode
        Rails.logger.info 'Order getOrder foundOrder'
        foundOrder = order
      end
    end
    foundOrder
  end


  WORLDPAY_STATUS = %w[
    IN_PROGRESS
    AUTHORISED
    REFUSED
    PENDING
    ACTIVE
    ETC
  ]

  VALID_CURRENCY_POUNDS_REGEX = /\A[-]?([0]|[1-9]+[0-9]*)(\.[0-9]{1,2})?\z/          # This is an expression for formatting currency as pounds
  VALID_CURRENCY_PENCE_REGEX = /\A[-]?[0-9]+\z/                                      # This is an expression for formatting currency as pence

  validates :id, presence: true
  validates :orderCode, presence: true
  validates :merchantId, presence: true
  #validates :totalAmount, presence: true, format: { with: VALID_CURRENCY_REGEX }
  validates :totalAmount, presence: true, format: { with: VALID_CURRENCY_POUNDS_REGEX }, :if => :isManualOrder?
  validates :totalAmount, presence: true, format: { with: VALID_CURRENCY_PENCE_REGEX },  :if => :isAutomatedOrder?
  #validate :validate_totalAmount
  validates :currency, presence: true
  validates :dateCreated, presence: true, length: { minimum: 8 }
  validates :worldPayStatus, presence: true, inclusion: { in: WORLDPAY_STATUS }, :if => :isOnlinePayment?
  #  validates :dateLastUpdated, presence: true, length: { minimum: 8 }
  validate :validate_dateLastUpdated
  validates :updatedByUser, presence: true
  validates :description, presence: true, length: { maximum: 250 }

  def self.worldpay_status_options_for_select
    (WORLDPAY_STATUS.collect {|d| [I18n.t('worldpay_status.'+d), d]})
  end

  ORDER_AMOUNT_TYPES = %w[
    POSITIVE
    NEGATIVE
  ]

  def includesOrderType? orderType
    Rails.logger.info 'includesOrderType? orderType:' + orderType.to_s
    Rails.logger.info 'returning: ' + (ORDER_AMOUNT_TYPES.include?(orderType)).to_s
    ORDER_AMOUNT_TYPES.include? orderType
  end

  def isValidRenderType? renderType
    Rails.logger.info 'isValidRenderType? renderType:' + renderType.to_s
    res = %w[].push(Order.new_registration_identifier) \
    	.push(Order.edit_registration_identifier).push(Order.renew_registration_identifier) \
    	.push(Order.extra_copycards_identifier).push(Order.editrenew_caused_new_identifier).include? renderType
    Rails.logger.info 'isValidRenderType? res: ' + res.to_s
    res
  end

  class << self
    def getPositiveType
     ORDER_AMOUNT_TYPES[0]
    end
  end

  class << self
    def getNegativeType
      ORDER_AMOUNT_TYPES[1]
    end
  end

  class << self
    def new_registration_identifier
      'NEWREG'
    end
  end

  class << self
    def edit_registration_identifier
      'EDIT'
    end
  end

  class << self
    def renew_registration_identifier
      'RENEW'
    end
  end

  class << self
    def extra_copycards_identifier
      'INCCOPYCARDS'
    end
  end
  
  class << self
    def editrenew_caused_new_identifier
      'EDITRENEW_CAUSED_NEW'
    end
  end

  def negateAmount
    Rails.logger.info 'Order, negateAmount, amountType: ' + self.amountType
    if self.amountType == Order.getNegativeType
      self.totalAmount = -self.totalAmount.to_f.abs
      Rails.logger.info 'amount negated: ' + self.totalAmount.to_s
    end
  end

  def unNegateAmount
    Rails.logger.info 'Order, unNegateAmount, amountType: ' + self.amountType
    if self.amountType == Order.getNegativeType
      self.totalAmount = self.totalAmount.to_f.abs
      Rails.logger.info 'amount unNegated: ' + self.totalAmount.to_s
    end
  end

  def isManualOrder?
    if !self.manualOrder.nil?
      self.manualOrder
    else
      false
    end
  end

  def isAutomatedOrder?
    !isManualOrder?
  end

  def isOnlinePayment?
    self.paymentMethod == 'ONLINE'
  end

  def isOfflinePayment?
    self.paymentMethod == 'OFFLINE'
  end


  private

  def poundsToPence
    if isManualOrder?
      multiplyAmount
    end
  end

  def penceToPounds
    if isManualOrder?
      divideAmount
    end
  end

  # This multiplies the amount up from pounds to pence
  def multiplyAmount
    self.totalAmount = (Float(self.totalAmount)*100).to_i
    Rails.logger.info 'multiplyAmount result:' + self.totalAmount.to_s
  end

  # This divides the amount down from pence back to pounds
  def divideAmount
    self.totalAmount = (Float(self.totalAmount)/100).to_s
    Rails.logger.info 'divideAmount result:' + self.totalAmount.to_s
  end

  def validate_totalAmount
    if self.totalAmount.to_s.include? "."
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
