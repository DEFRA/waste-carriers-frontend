class OrderItem < Ohm::Model

  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attribute :amount
  attribute :currency
  attribute :lastUpdated
  attribute :description
  attribute :reference

  class << self
    def init (order_items_hash)
      orderItem = OrderItem.create
      order_items_hash.each do |k, v|
        orderItem.send(:update, {k.to_sym => v})
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
