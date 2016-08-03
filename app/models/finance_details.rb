class FinanceDetails < Ohm::Model

  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attribute :balance

  set :orders, :Order
  set :payments, :Payment

  class << self
    def init (fd_hash)
      fd = FinanceDetails.create
      normal_attributes = Hash.new
      fd_hash.each do |k, v|
        case k.to_s
        when 'orders'
          if v #array of order hashes
            v.each do |order_hash|
              fd.orders.add(Order.init(order_hash))
            end
          end #if
        when 'payments'
          if v #array of payment hashes
            v.each do |payment_hash|
              fd.payments.add(Payment.init(payment_hash))
            end
          end #if
        else #normal string attribute
          normal_attributes.store(k, v)
        end #case
      end

      fd.update_attributes(normal_attributes)

      fd.save
      fd
    end
  end

  def to_hash
    h = self.attributes.to_hash
    h['payments'] =  payments.map { |payment| payment.to_hash}   if self.payments && self.payments.size > 0
    h['orders'] = orders.map { |order| order.to_hash}   if self.orders && self.orders.size > 0
    h
  end

  def to_json
    to_hash.to_json
  end

end
