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

              fd_order = Order.init(order_hash)

              #Rails.logger.info 'orders size before ' + fd.orders.size.to_s
              fd.orders.each do |checkOrder|
                #Rails.logger.info '-----------------'
                #Rails.logger.info 'before check order: ' + checkOrder.attributes.to_s
              end

              # add to oder list
              fd.orders.add fd_order

              # Alan idea
              #fd.orders.replace([fd_order])

              #Rails.logger.info 'orders size after ' + fd.orders.size.to_s
              fd.orders.each do |checkOrder|
                #Rails.logger.info '-----------------'
                #Rails.logger.info 'FD id: ' + fd.id + ' Order id: ' + checkOrder.id
                #Rails.logger.info 'after check order: ' + checkOrder.to_json.to_s
              end

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
          fd.send(:update, {k.to_sym => v})
        end #case
      end
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
