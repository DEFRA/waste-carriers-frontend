#Controller for handling the responses received from Worldpay (via the user's browser)

class WorldpayController < ApplicationController

  include WorldpayHelper
  include RegistrationsHelper

  def success
    #TODO - redirect to some other page after processing/saving the payment
    #redirect_to paid_path
    @registration = Registration[session[:registration_id]]

    if process_payment
      update_order
      
      # Get render type from session
      renderType = session[:renderType]
      
      case renderType
      when Order.new_registration_identifier
        # new registrations
        next_step = if user_signed_in?
        
            # Attempt to activate registration
            #Registration.activate_registrations(current_user)
            Registration.send_registered_email(current_user, @registration)
            
            finish_path
          elsif agency_user_signed_in?
            
            # Attempt to activate registration
            #Registration.activate_registrations(current_agency_user)
            Registration.send_registered_email(current_agency_user, @registration)
            
            finishAssisted_path
          else
            send_confirm_email Registration.find_by_id(session[:registration_uuid])
            pending_path
          end
      when Order.edit_registration_identifier, Order.renew_registration_identifier
        # edit/renew registration
        
        Rails.logger.info 'Test the routing from Worldpay for Edit/renew registration'
        
        next_step = complete_edit_renew_path
      when Order.extra_copycards_identifier
        # extra copy cards
        
        # TODO: Insert appropriate routing for copy cards routes here
        next_step = complete_copy_cards_path
      end
      
      #
      # This should be an acceptable time to delete the render type and 
      # the order code from the session, as these are used for payment 
      # and if reached here payment request succeeded
      #
      session.delete(:renderType)
      session.delete(:orderCode)
      
    else
      # Used to redirect_to WorldpayController::Error however that doesn't actually
      # exist, plus the plan as discussed with Georg was to redirect back to the payment
      # summary page but display the error details.
      next_step = upper_payment_path
    end

    redirect_to next_step

  end

  def failure
  	#TODO - Process response and edirect...
    process_payment
  end

  def pending
  	#TODO - Process response and edirect...
    process_payment
  end

  def cancel
  	#TODO - Process response and edirect...
    #process_payment
    flash[:notice] = 'You have cancelled your payment.'
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
    logger.info "Received order notification message from Worldpay..."
    puts '++++++++++++++++++++++++++++++++++++++++++++++'
    puts '+++++ Worldpay Notification Response +++++++++'
    puts '++++++++++++++++++++++++++++++++++++++++++++++'
    puts request.body.read
    puts '++++++++++++++++++++++++++++++++++++++++++++++'
    render nothing: true
  end

  private

    def process_payment
      payment_processed = false
      orderKey = params[:orderKey] || ''
      paymentAmount = params[:paymentAmount] || ''
      paymentCurrency = params[:paymentCurrency] || ''
      paymentStatus = params[:paymentStatus] || ''
      mac = params[:mac] || ''
      if !validate_worldpay_return_parameters(orderKey,paymentAmount,paymentCurrency,paymentStatus,mac)
        logger.error 'Validation of Worldpay return parameters failed. MAC verification failed!'
        # TODO Possibly need to do something more meaningful with the fact the MAC check has failed
        payment_processed = false
      else
        orderCode = orderKey.split('^').at(2)

        now = Time.now.utc
        #now = Time.now.utc.xmlschema
        @payment = Payment.new
        @payment.dateReceived = now
        @payment.dateReceived_year = now.year
        @payment.dateReceived_month = now.month
        @payment.dateReceived_day = now.day
        #We don't need to set the dateEntered; this is done within the service
        #@payment.dateEntered = now
        # TODO get the user if not yet logged in (still to be activated)
        @payment.updatedByUser = @registration.accountEmail
        @payment.amount = paymentAmount.to_i
        @payment.orderKey = orderCode
        @payment.currency = paymentCurrency
        @payment.paymentType = 'WORLDPAY'
        @payment.worldPayPaymentStatus = paymentStatus
        @payment.mac_code = mac
        @payment.registrationReference = 'Worldpay'
        @payment.comment = 'Paid via Worldpay'

        #TODO re-enable validation and saving - current validation rules are geared towards offline payments
        if @payment.valid?
          logger.debug "registration uuid: #{session[:registration_uuid]}"
          @payment.save! session[:registration_uuid]
          #@payment.save(:validate => false)
          payment_processed = true
        else
          logger.error 'Payment is not valid! ' + @payment.errors.messages.to_s
          payment_processed = false
          #TODO: what does this do? -need to replace it with explicit save
          @payment.save(:validate => false)
        end
      end

      payment_processed
    end

    def update_order
      #TODO better pass in as variables?
      orderCode = @payment.orderKey
      status = @payment.worldPayPaymentStatus

      reg = Registration.find_by_id(session[:registration_uuid])

      # Get the current_order from the registration
      ord = reg.getOrder( orderCode)
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

      logger.info '---- Adding to list: '
      ord.order_items.each do |item|
        logger.info 'item: ' + item.to_json.to_s
        # Test Re-add order items from original order
        @order.order_items.add item
      end

      logger.info  '***** The @order is:'
      logger.info  @order.attributes
      logger.info  '*****'

      if @order.valid?
        if @order.save! reg.uuid
          # Re-get registration so its data is up to date, for later use
          @registration = Registration.find_by_id(session[:registration_uuid])
          logger.info 'Re-populated @registration from the database'
        else
          # Errored saving order
          logger.error "CODE ERROR: this should not happen if code implemented propery"
        end
      else
        logger.error "CODE ERROR: this should not happen if code implemented propery"
        logger.error "The order is not valid! " + @order.errors.full_messages.to_s
      end

    end #update_order

end
