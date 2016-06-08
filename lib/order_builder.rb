class OrderBuilder

  attr_reader :registration_order
  attr_accessor :current_user

  def initialize(registration_order)
    @registration_order = registration_order
    @registration = registration_order.current_registration
  end

  def self.item_types
    {
      new: 'NEW',
      edit: 'EDIT',
      renew: 'RENEW',
      irrnew: 'IRRENEW',
      copy_cards: 'COPY_CARDS',
      charge_adjust: 'CHARGE_ADJUST',
      ir_import: 'IR_IMPORT'
    }
  end

  def self.standard_order_item(options = {})
    defaults = {
      amount: 0,
      description: '',
      reference: '',
      type: self.item_types[:new]
    }

    options.reverse_merge!(defaults)

    order_item = OrderItem.new(
      amount: options[:amount],
      currency: 'GBP',
      description: options[:description],
      reference: options[:reference],
      type: options[:type]
    )
  end

  def self.order_item_for_type(type)
    order_items = {}
    order_items[:change_caused_new] = self.standard_order_item(
      description: I18n.t('registrations.order.editFullFee'),
      amount: Rails.configuration.fee_registration
      )
    order_items[:change_reg_type] = self.standard_order_item(
      description: I18n.t('registrations.order.edit'),
      amount: Rails.configuration.fee_reg_type_change,
      type: self.item_types[:edit]
      )
    order_items[:renew] = self.standard_order_item(
      description: I18n.t('registrations.order.renewal'),
      amount: Rails.configuration.fee_renewal,
      type: self.item_types[:renew]
      )
    order_items[:new] = self.standard_order_item(
      description: I18n.t('registrations.order.initial'),
      amount: Rails.configuration.fee_registration
      )
    order_items[:edit] = nil # nil because basic edits are free of charge
    order_items[type]
  end

  def indicates_new_registration?
    order_items = @registration_order.order_types
    order_items.include?(:new) || order_items.include?(:change_caused_new) || order_items.include?(:renew)
  end

  def order_items
    registration_order_items = @registration_order.order_types.map do |order_type|
      self.class.order_item_for_type(order_type)
    end
    registration_order_items.compact
  end

  def copycard_order_item
    card_count = @registration.copy_cards.to_i
    if card_count > 0
      self.standard_order_item(
        description: I18n.t('registrations.order.copyCards', amount: card_count.to_s),
        amount: card_count * Rails.configuration.fee_copycard,
        type: self.item_types[:copy_cards]
        )
    else
      nil
    end
  end

  def order(order_code = nil)
    now = Time.now.utc.xmlschema

    order = Order.new(
      orderId: Time.now.to_i.to_s,
      orderCode: order_code || Time.now.to_i.to_s,
      totalAmount: total_fee,
      amountType: Order.getPositiveType,
      currency: 'GBP',
      updatedByUser: current_user.try(:email) || @registration.accountEmail,
      description: 'Some description', # TODO: implement new method to generate this based on order_helper #generateOrderDescription
      dateCreated: now,
      dateLastUpdated: now
    )

    if @registration.payment_type === "bank_transfer"
      order.paymentMethod = 'OFFLINE'
      order.merchantId = 'n/a'
      order.worldPayStatus = 'n/a'
    else
      order.paymentMethod = 'ONLINE'
      order.merchantId = OrderController.helpers.worldpay_merchant_code(current_user.try(:is_agency_user?).present?)
      order.worldPayStatus = 'IN_PROGRESS'
    end

    order.save
    order_items.each do |order_item|
      order_item.save
      order.order_items.add(order_item)
    end

    return order
  end

  def registration_fee
    order_items.map(&:amount).inject(0, &:+)
  end

  def registration_fee_money
    Money.new(registration_fee)
  end

  def copycard_fee
    @registration.copy_cards.to_i * Rails.configuration.fee_copycard
  end

  def total_fee
    registration_fee + copycard_fee
  end

  def total_fee_money
    Money.new(registration_fee + copycard_fee)
  end

end