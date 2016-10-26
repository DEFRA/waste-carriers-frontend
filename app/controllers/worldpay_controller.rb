#Controller for handling the responses received from Worldpay (via the user's browser)

class WorldpayController < ApplicationController

  include WorldpayHelper
  include RegistrationsHelper

  before_action :set_registration

  def success
    if process_payment
      update_order

      order_type = params[:order_type]

      # Refresh registration from the Java services / Mongo after payments have been applied
      @registration = Registration.find_by_id(@registration.uuid)

      # If on the Digital route, send the new Registration email.
      if @registration.digital_route? and !order_type.eql?(Order.extra_copycards_identifier)
        if user_signed_in?
          logger.debug 'Send registered email (as current_user)'
          Registration.send_registered_email(current_user, @registration)
        else
          logger.debug 'Send registered email (as not signed in)'
          @user = User.find_by_email(@registration.accountEmail)
          Registration.send_registered_email(@user, @registration)
        end
      end

      # Now decide which page we'll redirect the user to.
      case order_type
      when Order.new_registration_identifier,
           Order.editrenew_caused_new_identifier,
           Order.renew_registration_identifier

        # This was a new registration (perhaps via an edit or IR renewal).
        next_step = if user_signed_in?
          finish_path(reg_uuid: @registration.reg_uuid)
        elsif agency_user_signed_in?
          finish_assisted_path(reg_uuid: @registration.reg_uuid)
        else
          confirmed_path(reg_uuid: @registration.reg_uuid)
        end
      when Order.edit_registration_identifier
        # An existing registration was edited.
        next_step = complete_edit_renew_path(id: @registration.uuid,
          edit_mode: session[:edit_mode],
          edit_result: session[:edit_result])
      when Order.extra_copycards_identifier
        # Extra copy cards were ordered.
        next_step = complete_copy_cards_path(@registration.uuid)
      end

    else # We get here if 'process_payment' returns false.
      next_step = upper_payment_path(@registration.reg_uuid, order_type: order_type)
    end

    redirect_to next_step
  end

  def failure
    # Refresh registration from the Java services / Mongo
    @registration = Registration.find_by_id(@registration.uuid)
    if process_payment
      # Should not get here as payment should have failed and thus return false
    else
      flash[:notice] = I18n.t('registrations.form.paymentFailed')
      redirect_to upper_payment_path(reg_uuid: @registration.reg_uuid, order_type: params[:order_type])
    end
  end

  def pending
    # Refresh registration from the Java services / Mongo
    @registration = Registration.find_by_id(@registration.uuid)
    process_payment
  end

  def cancel
    # Refresh registration from the Java services / Mongo
    @registration = Registration.find_by_id(@registration.uuid)
    if process_payment
      # should not get here as payment was cancelled
    else
      flash[:notice] = I18n.t('registrations.form.paymentCancelled')
      redirect_to upper_payment_path(reg_uuid: @registration.reg_uuid, order_type: params[:order_type])
    end
  end

  def dateReceived
    Date.current
  end

  # TODO Remove this method once Worldpay order notifications are integrated
  def order_notification
  end

  # TODO Remove this method once Worldpay refunds are integrated into finance details pages
  def newRefund
    render "refund"
  end

  # TODO Remove this method once Worldpay refunds are integrated into finance details pages
  def updateNewRefund
    request_refund_from_worldpay
    render nothing: true
  end

  # POST from Worldpay
  def update_order_notification
    logger.debug "Received order notification message from Worldpay..."
    logger.debug '++++++++++++++++++++++++++++++++++++++++++++++'
    logger.debug '+++++ Worldpay Notification Response +++++++++'
    logger.debug '++++++++++++++++++++++++++++++++++++++++++++++'
    logger.debug '++++++++++++++++++++++++++++++++++++++++++++++'
    render nothing: true
  end

  private

  def process_payment
    payment_processed = false
    orderKey = params[:orderKey] || ''
    orderCode = orderKey.split('^').at(2)
    paymentAmount = params[:paymentAmount] || ''
    paymentCurrency = params[:paymentCurrency] || ''
    paymentStatus = params[:paymentStatus] || ''
    mac = params[:mac] || ''
    if !validate_worldpay_return_parameters(orderKey, paymentAmount, paymentCurrency, paymentStatus,mac)
      logger.error 'Validation of Worldpay return parameters failed. MAC verification failed!'
      # TODO Possibly need to do something more meaningful with the fact the MAC check has failed

      # Update order to reflect failed payment status
      order = @registration.getOrder(orderCode)
      now = Time.now.utc.xmlschema
      order.dateLastUpdated = now
      order.worldPayStatus = 'VERIFICATIONFAILED'
      order.save! @registration.reg_uuid

      payment_processed = false
    elsif paymentStatus == 'AUTHORISED'
      now = Time.now.utc
      #now = Time.now.utc.xmlschema
      @payment = Payment.new
      @payment.dateReceived = now
      @payment.dateReceived_year = now.year
      @payment.dateReceived_month = now.month
      @payment.dateReceived_day = now.day
      # We don't need to set the dateEntered; this is done within the service
      # TODO get the user if not yet logged in (still to be activated)
      @payment.updatedByUser = @registration.accountEmail
      @payment.amount = paymentAmount.to_i
      @payment.orderKey = orderCode
      @payment.currency = paymentCurrency
      @payment.paymentType = 'WORLDPAY'
      @payment.worldPayPaymentStatus = paymentStatus
      @payment.mac_code = mac
      @payment.registrationReference = 'Worldpay'
      @payment.comment = I18n.t('registrations.form.paymentWorldPay')

      # TODO re-enable validation and saving - current validation rules are geared towards offline payments
      if @payment.valid?
        logger.debug "registration uuid: #{@registration.reg_uuid}"
        if @payment.save! @registration.uuid
          #@payment.save(:validate => false)
          payment_processed = true
        end
      else
        logger.error 'Payment is not valid! ' + @payment.errors.messages.to_s
        payment_processed = false
        # TODO: what does this do? -need to replace it with explicit save
        @payment.save(:validate => false)
      end
    else
      logger.error 'Payment status was not successful, paymentStatus: ' + paymentStatus.to_s + " for order: " + orderCode.to_s

      # Update order to reflect failed payment status
      if @registration
        order = @registration.getOrder(orderCode)
        now = Time.now.utc.xmlschema
        order.dateLastUpdated = now
        order.worldPayStatus = paymentStatus
        order.save! @registration.uuid
      else
        logger.error 'There is no @registration. Cannot update registration.'
      end

      payment_processed = false
    end

    payment_processed
  end

  def update_order
    #TODO better pass in as variables?
    orderCode = @payment.orderKey
    status = @payment.worldPayPaymentStatus

    # Re-get the registration from Java / Mongo to ensure orders are all present
    @registration = Registration.find_by_id(@registration.uuid)

    reg = @registration

    # Get the current_order from the registration
    ord = reg.getOrder(orderCode)
    #ord = reg.finance_details.first.orders.first

    @order = Order.init(ord.attributes)

    #TODO Will need to set other payment methods accordingly
    now = Time.now.utc.xmlschema
    #@order.id = ord.id
    #@order.merchantId = worldpay_merchant_code
    #@order.totalAmount = reg.total_fee
    #@order.orderCode = orderCode
    @order.worldPayStatus = status
    @order.dateLastUpdated = now
    @order.updatedByUser = reg.accountEmail
    #@order.description = 'Updated order in WP contorller'
    #@order.prefix_options[:id] = session[:registration_id]

    @order.save

    ord.order_items.each do |item|
      # Test Re-add order items from original order
      @order.order_items.add item
    end

    if @order.valid?
      if @order.save! reg.uuid
        if session[:edit_mode]
          logger.debug "edited registration id: #{@registration.id}"
          #
          # BUG:: The following line causes a services save of the registration in a log line for all routes that use the edit_mode variable
          # This will always be wrong as the order was just saved to the registraion, To ensure that you have at least the order you just save
          # you must do:
          #
          # # Get the updated regsitration from the services, (albeit it is returned in the order.save method, but we throw that away so need to re-request it
          # regFromDB = Registration.find_by_id(@registration.uuid)
          # # Update the finance details in the local registration with that from the remote object
          # @registration.finance_details.replace([regFromDB.finance_details.first])
          #
          # NOTE: Ideally we need something better here as other data, other than just finance details could have changed.
          #
          #logger.error "Failed to save registration #{@registration.id}" unless @registration.save!
        end


        # Re-get registration so its data is up to date, for later use
        @registration = Registration.find_by_id(@registration.uuid)

        logger.debug 'Re-populated @registration from the database'
      else
        # Errored saving order
        logger.error "CODE ERROR: this should not happen if code implemented propery"
      end
    else
      logger.error "CODE ERROR: this should not happen if code implemented propery"
      logger.error "The order is not valid! " + @order.errors.full_messages.to_s
    end

  end #update_order

  def set_registration
    @registration = Registration.find(reg_uuid: params[:reg_uuid]).first
  end

end
