class Order < Ohm::Model

  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  WORLDPAY_STATUS = %w[
    IN_PROGRESS
    AUTHORISED
    REFUSED
    PENDING
    ACTIVE
    ETC
  ]

  ORDER_AMOUNT_TYPES = %w[
    POSITIVE
    NEGATIVE
  ]

  VALID_CURRENCY_POUNDS_REGEX = /\A[-]?([0]|[1-9]+[0-9]*)(\.[0-9]{1,2})?\z/          # This is an expression for formatting currency as pounds
  VALID_CURRENCY_PENCE_REGEX = /\A[-]?[0-9]+\z/                                      # This is an expression for formatting currency as pence

  attribute :orderId              # Used to identify the order by the Java Services
  attribute :orderCode            # Used to identify the order by the Rails application
  index :orderCode

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

  validates :id, presence: true
  validates :orderCode, presence: true
  validates :merchantId, presence: true
  #validates :totalAmount, presence: true, format: { with: VALID_CURRENCY_REGEX }
  validates :totalAmount, presence: true, format: { with: VALID_CURRENCY_POUNDS_REGEX }, :if => :is_manual_order?
  validates :totalAmount, presence: true, format: { with: VALID_CURRENCY_PENCE_REGEX },  :if => :is_automated_order?
  #validate :validate_totalAmount
  validates :currency, presence: true
  validates :dateCreated, presence: true, length: { minimum: 8 }
  validates :worldPayStatus, presence: true, inclusion: { in: WORLDPAY_STATUS }, :if => :is_online_payment?
  #  validates :dateLastUpdated, presence: true, length: { minimum: 8 }
  validate :validate_dateLastUpdated
  validates :updatedByUser, presence: true
  validates :description, presence: true, length: { maximum: 250 }

  # Creates a new Order object from an order-formatted hash
  # @param order_hash [Hash] the order-formatted hash
  # @return [Order] the Ohm-derived Order object.
  def self.init (order_hash)
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

  # Returns the payment from the registration matching the orderCode
  def self.getOrder(registration, orderCode)
    foundOrder = nil
    registration.finance_details.first.orders.each do |order|
      Rails.logger.debug 'Payment getOrder ' + order.orderCode.to_s
      if orderCode == order.orderCode
        Rails.logger.debug 'Order getOrder foundOrder'
        foundOrder = order
      end
    end
    foundOrder
  end

  def self.worldpay_status_options_for_select
    WORLDPAY_STATUS.collect {|d| [I18n.t('worldpay_status.'+d), d]}
  end

  def self.getPositiveType
   ORDER_AMOUNT_TYPES[0]
  end

  def self.getNegativeType
    ORDER_AMOUNT_TYPES[1]
  end

  def self.new_registration_identifier
    'NEWREG'
  end

  def self.edit_registration_identifier
    'EDIT'
  end

  def self.renew_registration_identifier
    'RENEW'
  end

  def self.extra_copycards_identifier
    'INCCOPYCARDS'
  end

  def self.editrenew_caused_new_identifier
    'EDITRENEW_CAUSED_NEW'
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
  def commit(registration_uuid)
    url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{registration_uuid}/orders.json"
    negateAmount
    poundsToPence
    Rails.logger.debug "about to post order"
    commited = true
    begin
      response = RestClient.post url,
        to_json,
        :content_type => :json,
        :accept => :json

      result = JSON.parse(response.body)
      save
      Rails.logger.debug "Commited order to service"
    rescue => e
      Airbrake.notify(e)
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
  # @return  [Boolean] true if PUT is successful (200), false if not
  def save!(registration_uuid)
    url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{registration_uuid}/orders/#{orderId}.json"
    commited = true
    begin
      response = RestClient.put url,
        to_json,
        :content_type => :json,
        :accept => :json
      result = JSON.parse(response.body)
      save
    rescue => e
      Airbrake.notify(e)
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

  def includesOrderType?(orderType)
    Rails.logger.debug 'includesOrderType? orderType:' + orderType.to_s
    Rails.logger.debug 'returning: ' + (ORDER_AMOUNT_TYPES.include?(orderType)).to_s
    ORDER_AMOUNT_TYPES.include? orderType
  end

  def isValidRenderType?(renderType)
    Rails.logger.debug 'isValidRenderType? renderType:' + renderType.to_s
    res = %w[].push(Order.new_registration_identifier) \
    	.push(Order.edit_registration_identifier).push(Order.renew_registration_identifier) \
    	.push(Order.extra_copycards_identifier).push(Order.editrenew_caused_new_identifier).include? renderType
    Rails.logger.debug 'isValidRenderType? res: ' + res.to_s
    res
  end

  def negateAmount
    Rails.logger.debug 'Order, negateAmount, amountType: ' + self.amountType
    if self.amountType == Order.getNegativeType
      self.totalAmount = -self.totalAmount.to_f.abs
      Rails.logger.debug 'amount negated: ' + self.totalAmount.to_s
    end
  end

  def unNegateAmount
    Rails.logger.debug 'Order, unNegateAmount, amountType: ' + self.amountType
    if self.amountType == Order.getNegativeType
      self.totalAmount = self.totalAmount.to_f.abs
      Rails.logger.debug 'amount unNegated: ' + self.totalAmount.to_s
    end
  end

  def is_manual_order?
    if !self.manualOrder.nil?
      self.manualOrder
    else
      false
    end
  end

  def is_automated_order?
    !is_manual_order?
  end

  def is_online_payment?
    self.paymentMethod == 'ONLINE'
  end

  def isOfflinePayment?
    self.paymentMethod == 'OFFLINE'
  end

  def copy_cards_order_item
    order_items.to_a.find{ |order_item| order_item.type == 'COPY_CARDS'}
  end

  def total_amount_money
    Money.new(totalAmount)
  end

  private

    def poundsToPence
      multiplyAmount if is_manual_order?
    end

    def penceToPounds
      divideAmount if is_manual_order?
    end

    # This multiplies the amount up from pounds to pence
    def multiplyAmount
      self.totalAmount = (Float(self.totalAmount)*100).to_i
      Rails.logger.debug 'multiplyAmount result:' + self.totalAmount.to_s
    end

    # This divides the amount down from pence back to pounds
    def divideAmount
      self.totalAmount = (Float(self.totalAmount)/100).to_s
      Rails.logger.debug 'divideAmount result:' + self.totalAmount.to_s
    end

    def validate_totalAmount
      if self.totalAmount.to_s.include? "."
        errors.add(:totalAmount, I18n.t('errors.messages.invalid')+ '. This is currently a Defect, Workaround, enter a value in pence only!' )
      end
    end

    def convert_dateLastUpdated
      begin
        if self.respond_to?('dateLastUpdated_year') and self.respond_to?('dateLastUpdated_month') and self.respond_to?('dateLastUpdated_day')
          Rails.logger.debug 'year FOUND'
          self.dateLastUpdated = Date.civil(self.dateLastUpdated_year.to_i, self.dateLastUpdated_month.to_i, self.dateLastUpdated_day.to_i)
          Rails.logger.debug 'dateReceived:' + self.dateReceived
        else
          Rails.logger.debug 'year not FOUND'
        end
      rescue ArgumentError
        false
      end
    end

    def validate_dateLastUpdated
      errors.add(:dateLastUpdated, I18n.t('errors.messages.invalid') ) unless convert_dateLastUpdated
    end

end
