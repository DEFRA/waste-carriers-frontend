class OrderItem < Ohm::Model

  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attribute :amount
  attribute :currency
  attribute :lastUpdated
  attribute :description
  attribute :reference
  attribute :type

  ORDERITEM_TYPES = %w(
    NEW
    EDIT
    RENEW
    IRRENEW
    COPY_CARDS
    CHARGE_ADJUST
    IR_IMPORT
  )

  def self.init (order_items_hash)
    orderItem = OrderItem.create
    orderItem.update_attributes(order_items_hash)
    orderItem.save
    orderItem
  end

  # returns a hash representation of the OrderItem object
  #
  # @param none
  # @return  [Hash]  the orderItem object as a hash
  def to_hash
    self.attributes.to_hash
  end

  # returns a JSON Java/DropWizard API compatible representation of the OrderItem object
  #
  # @param none
  # @return  [String]  the orderItem object in JSON form
  def to_json
    to_hash.to_json
  end

end
