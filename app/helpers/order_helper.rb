module OrderHelper

  def showRegistrationFee? renderType
    renderType.eql? Order.new_registration_identifier
  end
  
  def showEditFee? renderType
    renderType.eql? Order.edit_registration_identifier
  end
  
  def showRenewalFee? renderType
    renderType.eql? Order.renew_registration_identifier
  end
  
  def showCopyCards? renderType
    renderType.eql? Order.new_registration_identifier or renderType.eql? Order.extra_copycards_identifier
  end
  
  def prepareOfflinePayment myRegistration, renderType
    myRegistration = calculate_fees myRegistration, renderType
    logger.info "offline copy cards: " + myRegistration.copy_cards.to_s
    logger.info "offline total fee: " + myRegistration.total_fee.to_s
    logger.info "renderType: " + renderType
    order = prepareOrder myRegistration, false, renderType
    order
  end

  def prepareOnlinePayment myRegistration, renderType
    myRegistration = calculate_fees myRegistration, renderType
    logger.info "online copy cards: " + myRegistration.copy_cards.to_s
    logger.info "online total fee: " + myRegistration.total_fee.to_s
    order = prepareOrder myRegistration, true, renderType
    order
  end
  
  def calculate_fees myRegistration, renderType
    logger.info "renderType: " + renderType.to_s
    # Calculate default fees based on page to render
    case renderType
    when Order.new_registration_identifier
      # New, Edit, Renew all use standard fee for now
      myRegistration.registration_fee = Rails.configuration.fee_registration
      myRegistration.copy_card_fee = myRegistration.copy_cards.to_i * Rails.configuration.fee_copycard
      myRegistration.total_fee = myRegistration.registration_fee + myRegistration.copy_card_fee
      logger.info "Create reg for new"
    when Order.edit_registration_identifier
      myRegistration.copy_cards = '0'
      myRegistration.registration_fee = Rails.config.fee_reg_type_change
      myRegistration.total_fee = myRegistration.registration_fee
      logger.info "Create reg for edit with charge"
    when Order.renew_registration_identifier
      myRegistration.copy_cards = '0'
      myRegistration.registration_fee = Rails.configuration.fee_renewal
      myRegistration.total_fee = myRegistration.registration_fee
      logger.info "Create reg for renewal"
    when Order.extra_copycards_identifier
      # Additional copy card has different initial fees
      myRegistration.copy_card_fee = myRegistration.copy_cards.to_i * Rails.configuration.fee_copycard
      myRegistration.total_fee = myRegistration.copy_card_fee
      logger.info "Create reg for copy cards"
    else
      logger.error "Unrecogniseable renderType: " + renderType + ", Should be one of (" \
      	+ Order.new_registration_identifier + "," + Order.edit_registration_identifier + "," \
      	+ Order.renew_registration_identifier + "," + Order.extra_copycards_identifier + ")"
      return
    end
    logger.info "copy card fee: " + myRegistration.copy_card_fee.to_s
    logger.info "total fee: " + myRegistration.total_fee.to_s
    myRegistration
  end
  
  def prepareOrder (myRegistration, useWorldPay = true, renderType)
    reg = myRegistration

    #TODO have a current_order method on the registration
    ord = reg.finance_details.first.orders.first

    @order = Order.create
    # Create order description to reflect type of order
    @order.description = generateOrderDescription(renderType, reg)

    if useWorldPay
      @order = updateOrderForWorldpay(@order, reg)
    else
      @order = updateOrderForOffline(@order, reg)
    end

    if showRegistrationFee? renderType
      # Ensure Order Id of newly created order remains the same as currently assumes orderId of first order?
      @order.orderId = ord.orderId
    else
      # 
      # NOTE: This may cause an issue down in the future because it generates a new ID on every commit, thus a back and rety 
      # will re-fire the commit creating a subsequent order.
      #
      # Further note: removed as if new order id should not be needed? needs testing
      #
      # @order.orderId = SecureRandom.uuid
      @order.orderId = session[:orderCode]
    end
    
    

    if showRegistrationFee? renderType
      # Add order item for Initial registration
      # Create Order Item
      orderItem = OrderItem.new
      orderItem.amount = Rails.configuration.fee_registration
      orderItem.currency = 'GBP'
      orderItem.description = 'Initial Registration'
      orderItem.reference = 'Reg: ' + reg.regIdentifier
      orderItem.save

      @order.order_items.add orderItem
    end
    
    if showEditFee? renderType
      # Add order item for Edit registration
      # Create Order Item
      orderItem = OrderItem.new
      orderItem.amount = Rails.configuration.fee_registration
      orderItem.currency = 'GBP'
      orderItem.description = 'Edit Registration'
      orderItem.reference = 'Reg: ' + reg.regIdentifier
      orderItem.save

      @order.order_items.add orderItem
    end
    
    if showRenewalFee? renderType
      # Add order item for Renewal registration
      # Create Order Item
      orderItem = OrderItem.new
      orderItem.amount = Rails.configuration.fee_registration
      orderItem.currency = 'GBP'
      orderItem.description = 'Renewal of Registration'
      orderItem.reference = 'Reg: ' + reg.regIdentifier
      orderItem.save

      @order.order_items.add orderItem
    end

    if showCopyCards? renderType
      # Add additional order items for copy card amount
      # Create Order Item
      orderItem = OrderItem.new
      orderItem.amount = @registration.copy_cards.to_i * Rails.configuration.fee_copycard
      orderItem.currency = 'GBP'
      orderItem.description = @registration.copy_cards.to_s + 'x Copy Cards'
      orderItem.reference = 'Reg: ' + reg.regIdentifier
      orderItem.save

      @order.order_items.add orderItem
    end
    
    logger.info '----------------------------'
    logger.info '----- Created ORDER --------'
    logger.info @order.to_json
    logger.info '----------------------------'

    @order
  end
  
  def generateOrderDescription renderType, myRegistration
  
    # Create order description to reflect type of order
    orderLabel = ''
    incCopyCards = ''
    registrationMessage = ' Waste Carrier Registration: ' + myRegistration.regIdentifier
    forRegistrationMessage = ' for ' + myRegistration.companyName
    plusMessage = ', Plus '
    copyCardMessage = myRegistration.copy_cards.to_i.to_s + ' copy cards'
    
    case renderType
    when Order.new_registration_identifier
      # new
      orderLabel = 'New' + registrationMessage + forRegistrationMessage
    when Order.edit_registration_identifier
      # edit
      orderLabel = 'Edit' + registrationMessage + forRegistrationMessage
    when Order.renew_registration_identifier
      # renew
      orderLabel = 'Renew' + registrationMessage + forRegistrationMessage
    when Order.extra_copycards_identifier
      # copy cards
      orderLabel = copyCardMessage + forRegistrationMessage
    end
    
    # Add copy card information aswell if not already included
    if showCopyCards? renderType and renderType != Order.extra_copycards_identifier
      incCopyCards = plusMessage + copyCardMessage
    end
    
    orderDescription = orderLabel + incCopyCards
    logger.debug 'orderDescription: ' + orderDescription
    orderDescription
  end
  def updateOrderForWorldpay myOrder, myRegistration
    myOrder = updateOrderGenerally myOrder, myRegistration
    myOrder.paymentMethod = 'ONLINE'
    myOrder.merchantId = worldpay_merchant_code
    myOrder.worldPayStatus = 'IN_PROGRESS'
#    myOrder.description = 'Updated registrations PRIOR to WP'
    myOrder
  end

  def updateOrderForOffline myOrder, myRegistration
    myOrder = updateOrderGenerally myOrder, myRegistration
    myOrder.paymentMethod = 'OFFLINE'
    myOrder.merchantId = 'n/a'
    myOrder.worldPayStatus = 'n/a'
#    myOrder.description = 'Updated registrations PRIOR to offline'
    myOrder
  end
  
  def updateOrderGenerally myOrder, myRegistration
    now = Time.now.utc.xmlschema
    myOrder.orderCode = Time.now.to_i.to_s
    myOrder.totalAmount = myRegistration.total_fee
    myOrder.currency = 'GBP'
    myOrder.dateCreated = now
    myOrder.dateLastUpdated = now
    myOrder.updatedByUser = myRegistration.accountEmail
    myOrder.amountType = Order.getPositiveType
    myOrder
  end
  
end