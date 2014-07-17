class Order < Ohm::Model

  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

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

  set :order_Items, :OrderItem

=begin
{"orderItems"=>[{"amount"=>2, "currency"=>"GBP", "reference"=>"KJ65"}], "orderCode"=>"1405600713639", "paymentMethod"=>"UNKNOWN", "merchantId"=>nil,
  "totalAmount"=>15400, "currency"=>"GBP", "dateCreated"=>nil, "worldPayStatus"=>nil, "dateLastUpdated"=>nil,
  "updatedByUser"=>nil, "description"=>"Initial Registration"}
=end

  class << self
    def init (order_hash)
      order = Order.create

      order_hash.each do |k, v|
        case k
        when 'orderItems'
            if v
              v.each do |item|
                orderItem = OrderItem.create
                item.each {|k1, v1| orderItem.send("#{k1}=",v1)}
                orderItem.save
              end
              order.orderItem.add orderItem
            end #if
        else
           order.send("#{k}=",v)
        end #case
      end
      order.save
      order
    end
  end

  WORLDPAY_STATUS = %w[
    PENDING
    ACTIVE
    ETC
  ]

  VALID_CURRENCY_REGEX = /\A[-]?[0-9.]+\z/    # This does not allow for a decimal point and currently works in pence only

  validates :orderCode, presence: true
  validates :merchantId, presence: true
  validates :totalAmount, presence: true, format: { with: VALID_CURRENCY_REGEX }
  validate :validate_totalAmount
  validates :currency, presence: true
  validates :dateCreated, presence: true, length: { minimum: 8 }
  validates :worldPayStatus, presence: true, inclusion: { in: WORLDPAY_STATUS }
  #  validates :dateLastUpdated, presence: true, length: { minimum: 8 }
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
