module RegistrationsHelper
  def validation_for(model, attribute)
    if model.errors[attribute].any?
      # Note: Calling raw() forces the characters to be un-escaped and thus HTML elements can be defined here
      raw("<span class=\"error-text\">#{model.errors.full_messages_for(attribute).first}</span>")
    else
      ""
    end
  end

  def format_date(string)
    d = string.to_date
    d.strftime('%A ' + d.mday.ordinalize + ' %B %Y')
  end

  def format_address(model)
    if model.postcode.nil?
      # Print International address
      "#{h(model.streetLine1)}<br />#{h(model.streetLine2)}<br />#{h(model.streetLine3)}<br />#{h(model.streetLine4)}<br />#{h(model.country)}".html_safe
    else
      if model.streetLine2.present?
        # Print UK Address Including Street line 2 (as its optional but been populated)
        "#{h(model.houseNumber)} #{h(model.streetLine1)}<br />#{h(model.streetLine2)}<br />#{h(model.townCity)}<br />#{h(model.postcode)}".html_safe
      else
        # Print UK Address
        "#{h(model.houseNumber)} #{h(model.streetLine1)}<br />#{h(model.townCity)}<br />#{h(model.postcode)}".html_safe
      end
    end
  end

  def one_full_message_per_invalid_attribute registration
    hash_without_base = registration.errors.messages.except :base

    hash_without_base.each_key do |key|
      singleton_array_of_first_element = Array.wrap(registration.errors.get(key).first)
      registration.errors.set key, singleton_array_of_first_element
    end

    registration.errors.full_messages
  end

  # TODO not sure what this should do now smart answers and lower tier have been merged
  def first_back_link registration
    path = if registration.metaData.first.route == 'DIGITAL'
      if user_signed_in?
        userRegistrations_path current_user.id
      else
        find_path
      end
    else
      registrations_path
    end

    link_to t('registrations.form.back_button_label'), path, class: 'button-secondary'
  end
  def isSmallWriteOffAvailable(registration)
    registration.finance_details.first and (Payment.isSmallWriteOff( registration.finance_details.first.balance) == true)
  end

  def isLargeWriteOffAvailable(registration)
    registration.finance_details.first.balance.to_i != 0
  end

  def isRefundAvailable(registration)
    registration.finance_details.first.balance.to_f < 0
  end

  def send_confirm_email(registration)
    user = registration.user
    user.current_registration = registration
    user.send_confirmation_instructions unless user.confirmed?
  end
  
  def setup_registration current_step, no_update=false
    @registration = Registration[ session[:registration_id]]
    @registration.add( params[:registration] ) unless no_update
    @registration.save
    logger.debug  @registration.attributes.to_s
    @registration.current_step = current_step
  end
  
  def prepareOfflinePayment myRegistration
    myRegistration = calculate_fees myRegistration
    order = prepareOrder false
    order
  end

  def prepareOnlinePayment myRegistration
    myRegistration = calculate_fees myRegistration
    logger.info "copy cards: " + myRegistration.copy_cards.to_s
    logger.info "total fee: " + myRegistration.total_fee.to_s
    order = prepareOrder true
    order
  end
  
  def calculate_fees myRegistration
    myRegistration.registration_fee = Rails.configuration.fee_registration
    myRegistration.copy_card_fee = myRegistration.copy_cards.to_i * Rails.configuration.fee_copycard
    myRegistration.total_fee = myRegistration.registration_fee + myRegistration.copy_card_fee
    myRegistration
  end
  
  def prepareOrder (useWorldPay = true)
    reg = Registration.find_by_id(session[:registration_uuid])

    #TODO have a current_order method on the registration
    ord = reg.finance_details.first.orders.first

    @order = Order.create

    if useWorldPay
      @order = updateOrderForWorldpay(@order)
    else
      @order = updateOrderForOffline(@order)
    end

    # Ensure Order Id of newly created order remains the same
    # TODO: Fix later as assumed orderId of first order?
    @order.orderId = ord.orderId

    # Get a orderItem object
    ordItem = ord.order_items.first

    isInitialRegistration = true
    if isInitialRegistration
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

    if @registration.copy_cards.to_i > 0
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

    @order
  end
  
  def updateOrderForWorldpay myOrder
    myOrder = updateOrderGenerally myOrder, @registration
    myOrder.paymentMethod = 'ONLINE'
    myOrder.merchantId = worldpay_merchant_code
    myOrder.worldPayStatus = 'IN_PROGRESS'
    myOrder.description = 'Updated registrations PRIOR to WP'
    myOrder
  end

  def updateOrderForOffline myOrder
    myOrder = updateOrderGenerally myOrder, @registration
    myOrder.paymentMethod = 'OFFLINE'
    myOrder.merchantId = 'n/a'
    myOrder.worldPayStatus = 'n/a'
    myOrder.description = 'Updated registrations PRIOR to WP'
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
    myOrder
  end
  
  def new_step_action current_step
    if current_step.eql? Registration::FIRST_STEP
      @registration = Registration.create
      session[:registration_id]= @registration.id
      logger.debug "creating new registration #{@registration.id}"
      m = Metadata.create

      if agency_user_signed_in?
        m.update :route => 'ASSISTED_DIGITAL'
        if @registration.accessCode.blank?
          @registration.update :accessCode => @registration.generate_random_access_code
        end
      else
        m.update :route => 'DIGITAL'
      end

      @registration.metaData.add m

    else
      @registration = Registration[ session[:registration_id]]
      logger.debug "retireving registration #{@registration.id}"
      m = Metadata.create
    end

    logger.debug "reg: #{@registration.id}  #{@registration.to_json}"

    if  session[:registration_progress].eql? 'IN_EDIT'
    end

    # TODO by setting the step here this should work better with forward and back buttons and urls
    # but this might have changed the behaviour
    @registration.current_step = current_step
    @registration.save
    logger.debug "new step action: #{current_step}"
    logger.debug "curret step: #{ @registration.current_step}"
    # Pass in current page to check previous page is valid
    # TODO had to comment this out for now because causing problems but will probably need to reinstate
    # check_steps_are_valid_up_until_current current_step

#    if (session[:registration_id])
#      #TODO show better page - the user should not be able to return to these pages after the registration has been saved
#      renderNotFound
#    end
  end

end
