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

      fd_hash.each do |k, v|
        case k
        when 'orders'
          if v #array of order hashes
            v.each do |order_hash|
              order = Order.init(order_hash)
              fd.orders.add order
            end
          end #if
        when 'payments'
          if v #array of payment hashes
            v.each do |payment_hash|
              payment = Payment.init(payment_hash)
              fd.payments.add payment
            end
          end #if
        else #normal string attribute
          fd.send("#{k}=",v)
        end #case
      end
      fd.save
      fd
    end
  end

end
