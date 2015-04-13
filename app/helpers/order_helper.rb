module OrderHelper
  def show_registration_fee?(my_registration, render_type)
    new_reg = render_type.eql?(Order.new_registration_identifier)
    expired_renewal = render_type.eql?(Order.renew_registration_identifier) &&
                      !my_registration.within_ir_renewal_window?
    new_reg || expired_renewal
  end

  def show_edit_fee?(render_type)
    render_type.eql?(Order.edit_registration_identifier)
  end

  def show_renewal_fee?(my_registration, render_type)
    render_type.eql?(Order.renew_registration_identifier) &&
      my_registration.within_ir_renewal_window?
  end

  def show_copy_cards?(render_type)
    render_type.eql?(Order.new_registration_identifier) ||
      render_type.eql?(Order.renew_registration_identifier) ||
      render_type.eql?(Order.editrenew_caused_new_identifier) ||
      render_type.eql?(Order.extra_copycards_identifier)
  end

  def show_edit_full_fee?(render_type)
    render_type.eql?(Order.editrenew_caused_new_identifier)
  end

  def prepareOfflinePayment(my_registration, render_type)
    my_registration = calculate_fees(my_registration, render_type)
    logger.info 'offline copy cards: ' + my_registration.copy_cards.to_s
    logger.info 'offline total fee: ' + my_registration.total_fee.to_s
    logger.info 'render_type: ' + render_type
    order = prepareOrder(my_registration, false, render_type)
    order
  end

  def prepareOnlinePayment(my_registration, render_type)
    my_registration = calculate_fees my_registration, render_type
    logger.info 'online copy cards: ' + my_registration.copy_cards.to_s
    logger.info 'online total fee: ' + my_registration.total_fee.to_s
    order = prepareOrder(my_registration, true, render_type)
    order
  end

  def calculate_fees(my_registration, render_type)
    logger.info 'render_type: ' + render_type.to_s
    
    # Ensure copy cards contains a valid value.
    my_registration.copy_cards = 0 unless my_registration.copy_cards
    
    # Fees common to all order types.
    my_registration.registration_fee = Money.new(0, 'GBP').cents
    my_registration.copy_card_fee = my_registration.copy_cards.to_i * Rails.configuration.fee_copycard
    
    # Calculate default fees based on page to render
    case render_type
    when Order.new_registration_identifier, Order.editrenew_caused_new_identifier
      my_registration.registration_fee = Rails.configuration.fee_registration
    when Order.edit_registration_identifier
      logger.debug 'edit result: ' + session[:edit_result].to_s
      if session[:edit_result].to_i == RegistrationsController::EditResult::CREATE_NEW_REGISTRATION
        my_registration.registration_fee = Rails.configuration.fee_registration
      else
        my_registration.registration_fee = Rails.configuration.fee_reg_type_change
      end
    when Order.renew_registration_identifier
      if my_registration.within_ir_renewal_window?
        my_registration.registration_fee = Rails.configuration.fee_renewal
      else
        my_registration.registration_fee = Rails.configuration.fee_registration
      end
    when Order.extra_copycards_identifier
      # No special fees.
    else
      logger.error 'Unrecogniseable render_type: ' + render_type.to_s
      return
    end
    
    # Calculate total
    my_registration.total_fee = my_registration.registration_fee + my_registration.copy_card_fee
    
    logger.debug format('Fees: registration=%d, copy cards=%d, total=%d',
                        my_registration.registration_fee,
                        my_registration.copy_card_fee,
                        my_registration.total_fee)

    my_registration
  end

  def prepareOrder(my_registration, useWorldPay = true, render_type)
    reg = my_registration

    # TODO: have a current_order method on the registration
    ord = reg.finance_details.first.orders.first

    @order = Order.create
    # Create order description to reflect type of order
    @order.description = generateOrderDescription(render_type, reg)

    if useWorldPay
      @order = updateOrderForWorldpay(@order, reg)
    else
      @order = updateOrderForOffline(@order, reg)
    end

    if show_registration_fee?(my_registration, render_type) || show_edit_full_fee?(render_type) || isIRRenewal?(my_registration, render_type)
      # Ensure Order Id of newly created order remains the same as currently
      # assumes orderId of first order?
      @order.orderId = ord.orderId
    else
      # Get order code from session, assume populated prior to entry of order /
      # new.
      @order.orderId = session[:orderCode]
    end

    if show_registration_fee?(my_registration, render_type)
      # Add order item for Initial registration
      # Create Order Item
      order_item = OrderItem.new
      order_item.amount = Rails.configuration.fee_registration
      order_item.currency = 'GBP'
      order_item.description = I18n.t('registrations.order.initial')
      order_item.reference = 'Reg: ' + reg.regIdentifier
      order_item.type = OrderItem::ORDERITEM_TYPES[0]
      order_item.save

      @order.order_items.add order_item
    end

    if show_edit_fee?(render_type)
      # Add order item for Edit registration
      # Create Order Item
      order_item = OrderItem.new
      order_item.amount = Rails.configuration.fee_reg_type_change
      order_item.currency = 'GBP'
      order_item.description = I18n.t('registrations.order.edit')
      order_item.reference = 'Reg: ' + reg.regIdentifier
      order_item.type = OrderItem::ORDERITEM_TYPES[1]
      order_item.save

      @order.order_items.add order_item
    end

    if show_renewal_fee?(my_registration, render_type)
      # Add order item for Renewal registration
      # Create Order Item
      order_item = OrderItem.new
      order_item.amount = Rails.configuration.fee_renewal
      order_item.currency = 'GBP'
      order_item.description = I18n.t('registrations.order.renewal')
      order_item.reference = 'Reg: ' + reg.regIdentifier
      order_item.type = OrderItem::ORDERITEM_TYPES[2]
      order_item.save

      @order.order_items.add order_item
    end

    if show_edit_full_fee?(render_type)
      # Add order item for Edit full fee registration
      # Create Order Item
      order_item = OrderItem.new
      order_item.amount = Rails.configuration.fee_registration
      order_item.currency = 'GBP'
      order_item.description = I18n.t('registrations.order.editFullFee')
      order_item.reference = 'Reg: ' + reg.regIdentifier
      order_item.type = OrderItem::ORDERITEM_TYPES[1]
      order_item.save

      @order.order_items.add order_item
    end

    if show_copy_cards?(render_type) && (@registration.copy_cards.to_i > 0)
      # Add additional order items for copy card amount
      # Create Order Item
      order_item = OrderItem.new
      order_item.amount = @registration.copy_cards.to_i * Rails.configuration.fee_copycard
      order_item.currency = 'GBP'
      order_item.description = I18n.t('registrations.order.copyCards', amount: @registration.copy_cards.to_s)
      order_item.reference = 'Reg: ' + reg.regIdentifier
      order_item.type = OrderItem::ORDERITEM_TYPES[4]
      order_item.save

      @order.order_items.add order_item
    end

    logger.info '----------------------------'
    logger.info '----- Created ORDER --------'
    logger.info @order.to_json
    logger.info '----------------------------'

    @order
  end

  def generateOrderDescription(render_type, my_registration)
    # Create order description to reflect type of order
    orderLabel = ''
    incCopyCards = ''
    copyCardMessage = I18n.t('registrations.order.ccMsg', :amount => my_registration.copy_cards.to_i.to_s)

    case render_type
    when Order.new_registration_identifier
      # new
      orderLabel = I18n.t('registrations.order.newRegistrationMsg', :regMsg => I18n.t('registrations.order.regMsg'), :identifier => my_registration.regIdentifier, :companyName => my_registration.companyName)
    when Order.edit_registration_identifier, Order.editrenew_caused_new_identifier
      # edit
      orderLabel = I18n.t('registrations.order.editRegistrationMsg', :regMsg => I18n.t('registrations.order.regMsg'), :identifier => my_registration.regIdentifier, :companyName => my_registration.companyName)
    when Order.renew_registration_identifier
      # renew
      if my_registration.within_ir_renewal_window?
        orderLabel = I18n.t('registrations.order.renewRegistrationMsg', :regMsg => I18n.t('registrations.order.regMsg'), :identifier => my_registration.regIdentifier, :companyName => my_registration.companyName)
      else
        orderLabel = I18n.t('registrations.order.newRegistrationMsg', :regMsg => I18n.t('registrations.order.regMsg'), :identifier => my_registration.regIdentifier, :companyName => my_registration.companyName)
      end
    when Order.extra_copycards_identifier
      # copy cards
      orderLabel = I18n.t('registrations.order.copyCardRegistrationMsg', :ccMsg => copyCardMessage, :companyName => my_registration.companyName)
    end

    # Add copy card information aswell if not already included
    if show_copy_cards?(render_type) && (render_type != Order.extra_copycards_identifier) && (my_registration.copy_cards.to_i > 0)
      incCopyCards = I18n.t('registrations.order.incCopyCardsMsg', :ccMsg => copyCardMessage)
    end

    orderDescription = orderLabel + incCopyCards
    logger.debug 'orderDescription: ' + orderDescription
    orderDescription
  end

  def updateOrderForWorldpay(my_order, my_registration)
    my_order = updateOrderGenerally my_order, my_registration
    my_order.paymentMethod = 'ONLINE'
    my_order.merchantId = worldpay_merchant_code
    my_order.worldPayStatus = 'IN_PROGRESS'
    my_order
  end

  def updateOrderForOffline(my_order, my_registration)
    my_order = updateOrderGenerally my_order, my_registration
    my_order.paymentMethod = 'OFFLINE'
    my_order.merchantId = 'n/a'
    my_order.worldPayStatus = 'n/a'
    my_order
  end

  def updateOrderGenerally(my_order, my_registration)
    now = Time.now.utc.xmlschema
    my_order.orderCode = Time.now.to_i.to_s
    my_order.totalAmount = my_registration.total_fee
    my_order.currency = 'GBP'
    my_order.dateCreated = now
    my_order.dateLastUpdated = now
    if current_user
      my_order.updatedByUser = current_user.email
    elsif current_agency_user
      my_order.updatedByUser = current_agency_user.email
    else
      my_order.updatedByUser = my_registration.accountEmail
    end
    my_order.amountType = Order.getPositiveType
    my_order
  end

  def isIRRenewal?(my_registration, render_type)
    # It is an IRRenewal if the render type is renewal, and the orignal reg
    # number is populated with an IR format value
    render_type.eql?(Order.renew_registration_identifier) &&
      my_registration.originalRegistrationNumber &&
      !my_registration.originalRegistrationNumber.empty? &&
      isIRRegistrationType(@registration.originalRegistrationNumber)
  end

end
