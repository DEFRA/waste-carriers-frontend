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
      logger.error {'Unrecognised render_type: ' + render_type.to_s}
      return
    end
    
    # Calculate total
    my_registration.total_fee = my_registration.registration_fee + my_registration.copy_card_fee
    
    logger.debug { format('Fees: registration=%d, copy cards=%d, total=%d',
                          my_registration.registration_fee,
                          my_registration.copy_card_fee,
                          my_registration.total_fee) }
  end

  # Creates and returns a new Order object based on the provided parameters.
  # The returned Order will have a payment method of 'UNKNOWN', and should be
  # updated using updateOrderForWorldpay() or updateOrderForOffline() when the
  # user's chosen payment method is known.
  def prepareGenericOrder(my_registration, render_type, order_uuid, order_code)
    # Update order-related fields on the Registration object.
    calculate_fees(my_registration, render_type)
    
    # Create a new Order object and initialise its fields.
    my_order = Order.create
    my_order.orderId = order_uuid
    my_order.orderCode = order_code
    my_order.description = generateOrderDescription(render_type, my_registration)
    updateOrderGenerally(my_order, my_registration)

    if show_registration_fee?(my_registration, render_type)
      # Add order item for Initial registration
      # Create Order Item
      order_item = OrderItem.new
      order_item.amount = Rails.configuration.fee_registration
      order_item.currency = 'GBP'
      order_item.description = I18n.t('registrations.order.initial')
      order_item.reference = 'Reg: ' + my_registration.regIdentifier
      order_item.type = OrderItem::ORDERITEM_TYPES[0]
      order_item.save()
      my_order.order_items.add(order_item)
    end

    if show_edit_fee?(render_type)
      # Add order item for Edit registration
      # Create Order Item
      order_item = OrderItem.new
      order_item.amount = Rails.configuration.fee_reg_type_change
      order_item.currency = 'GBP'
      order_item.description = I18n.t('registrations.order.edit')
      order_item.reference = 'Reg: ' + my_registration.regIdentifier
      order_item.type = OrderItem::ORDERITEM_TYPES[1]
      order_item.save()
      my_order.order_items.add(order_item)
    end

    if show_renewal_fee?(my_registration, render_type)
      # Add order item for Renewal registration
      # Create Order Item
      order_item = OrderItem.new
      order_item.amount = Rails.configuration.fee_renewal
      order_item.currency = 'GBP'
      order_item.description = I18n.t('registrations.order.renewal')
      order_item.reference = 'Reg: ' + my_registration.regIdentifier
      order_item.type = OrderItem::ORDERITEM_TYPES[2]
      order_item.save()
      my_order.order_items.add(order_item)
    end

    if show_edit_full_fee?(render_type)
      # Add order item for Edit full fee registration
      # Create Order Item
      order_item = OrderItem.new
      order_item.amount = Rails.configuration.fee_registration
      order_item.currency = 'GBP'
      order_item.description = I18n.t('registrations.order.editFullFee')
      order_item.reference = 'Reg: ' + my_registration.regIdentifier
      order_item.type = OrderItem::ORDERITEM_TYPES[1]
      order_item.save()
      my_order.order_items.add(order_item)
    end

    if show_copy_cards?(render_type) && (my_registration.copy_cards.to_i > 0)
      # Add additional order items for copy card amount
      # Create Order Item
      order_item = OrderItem.new
      order_item.amount = my_registration.copy_cards.to_i * Rails.configuration.fee_copycard
      order_item.currency = 'GBP'
      order_item.description = I18n.t('registrations.order.copyCards', amount: my_registration.copy_cards.to_s)
      order_item.reference = 'Reg: ' + my_registration.regIdentifier
      order_item.type = OrderItem::ORDERITEM_TYPES[4]
      order_item.save()
      my_order.order_items.add(order_item)
    end

    my_order
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

    # Add copy card information as well if not already included.
    if show_copy_cards?(render_type) && (render_type != Order.extra_copycards_identifier) && (my_registration.copy_cards.to_i > 0)
      incCopyCards = I18n.t('registrations.order.incCopyCardsMsg', :ccMsg => copyCardMessage)
    end

    orderDescription = orderLabel + incCopyCards
    orderDescription
  end

  # Updates an Order object, to reflect that the user has chosen to pay for the
  # Order via Worldpay.
  def updateOrderForWorldpay(my_order, my_registration)
    updateOrderGenerally(my_order, my_registration)
    my_order.paymentMethod = 'ONLINE'
    my_order.merchantId = worldpay_merchant_code
    my_order.worldPayStatus = 'IN_PROGRESS'
  end

  # Updates an Order object, to reflect that the user has chosen to pay for the
  # Order via an offline process (eg bank transfer).
  def updateOrderForOffline(my_order, my_registration)
    updateOrderGenerally(my_order, my_registration)
    my_order.paymentMethod = 'OFFLINE'
  end

  def updateOrderGenerally(my_order, my_registration)
    # Payment-method related fields; set these to non-specific values.
    my_order.paymentMethod = 'UNKNOWN'
    my_order.merchantId = 'n/a'
    my_order.worldPayStatus = 'n/a'
    
    # Other fields.
    now = Time.now.utc.xmlschema
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
  end

  def isIRRenewal?(my_registration, render_type)
    # It is an IRRenewal if the render type is renewal, and the orignal reg
    # number is populated with an IR format value
    render_type.eql?(Order.renew_registration_identifier) &&
      my_registration.originalRegistrationNumber &&
      !my_registration.originalRegistrationNumber.empty? &&
      isIRRegistrationType(my_registration.originalRegistrationNumber)
  end

  def add_new_order_to_registration(my_registration, my_order, skip_registration_validation: false)
    unless skip_registration_validation
      unless my_registration.valid?
        logger.error {'add_new_order_to_registration: my_registration is not valid: ' + my_registration.errors.messages.to_s}
        return false
      end
    end

    unless my_order.valid?
      logger.error {'add_new_order_to_registration: my_order is not valid: ' + my_order.errors.full_messages.to_s}
      return false
    end

    if my_order.commit(my_registration.uuid)
      # Load the registration from Mongo, and update the local Redis version's
      # finance details (with the order details), then save back to Redis.
      regFromDB = Registration.find_by_id(my_registration.uuid)
      my_registration.finance_details.replace([regFromDB.finance_details.first])
      my_registration.save
    else
      logger.error {'add_new_order_to_registration: Failed to commit my_order: ' + my_order.exception.to_s}
      my_order.errors.add(:exception, my_order.exception.to_s)
      return false
    end

    return true
  end
  
  def update_order_on_registration(my_registration, my_order)
    unless my_order.valid?
      logger.error {'update_order_on_registration: my_order is not valid: ' + my_order.errors.full_messages.to_s}
      return false
    end

    if my_order.save!(my_registration.uuid)
      # Load the registration from Mongo, and update the local Redis version's
      # finance details (with the order details), then save back to Redis.
      regFromDB = Registration.find_by_id(my_registration.uuid)
      my_registration.finance_details.replace([regFromDB.finance_details.first])
      my_registration.save
    else
      logger.error {'update_order_on_registration: Failed to save my_order: ' + my_order.exception.to_s}
      my_order.errors.add(:exception, my_order.exception.to_s)
      return false
    end

    return true
  end
  
  
end
