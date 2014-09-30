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
  
  ORDERITEM_TYPES = %w[
    NEW
	EDIT
	RENEW
	IRRENEW
	COPY_CARDS
	CHARGE_ADJUST
  ]

  class << self
    def init (order_items_hash)
      orderItem = OrderItem.create
      order_items_hash.each do |k1, v1|
        orderItem.send(:update, {k1.to_sym => v1})
      end
      orderItem.save
      orderItem
    end
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
