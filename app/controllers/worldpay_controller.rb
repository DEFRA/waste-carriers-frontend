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
      
      if @registration.digital_route? and !renderType.eql?(Order.extra_copycards_identifier)
        if user_signed_in?
          logger.info 'Send registered email (as current_user)'
          Registration.send_registered_email(current_user, @registration)
        else
          logger.info 'Send registered email (as not signed in)'
          @user = User.find_by_email(@registration.accountEmail)
          Registration.send_registered_email(@user, @registration)
        end
      end

      case renderType
      when Order.new_registration_identifier
        # new registrations
        next_step = if user_signed_in?

          # Attempt to activate registration
          #Registration.send_registered_email(current_user, @registration)

          finish_path
        elsif agency_user_signed_in?

          # Attempt to activate registration
          #Registration.send_registered_email(current_agency_user, @registration)

          finishAssisted_path
        else
        
          # Need to get newly created (possibly unactivated) user to pass to send email
          #current_user = User.find_by_email(@registration.accountEmail)
          #if current_user
            # Attempt to activate registration
            #Registration.send_registered_email(current_user, @registration)
          #else
            # This shouldnt be possible as a account email will always have a value and registration 
            # will always be a DIGITAL as agency registrations are picked up in agency_user_signed_in? check
            #logger.error 'Error: Cannot find user from email: ' + @registration.accountEmail.to_s
          #end
        
          confirmed_path
        end
      when Order.edit_registration_identifier
        # edit/renew registration
        next_step = complete_edit_renew_path(@registration.uuid)
      when Order.renew_registration_identifier
        # edit/renew registration
        next_step = if isIRRegistrationType @registration.originalRegistrationNumber
          if user_signed_in?
            # Send registered email
            #Registration.send_registered_email(current_user, @registration)
            complete_edit_renew_path(@registration.uuid)
          elsif agency_user_signed_in?
            # Send registered email
            #Registration.send_registered_email(current_agency_user, @registration)
            complete_edit_renew_path(@registration.uuid)
          else
            confirmed_path
          end
        else
          complete_edit_renew_path(@registration.uuid)
        end
      when Order.extra_copycards_identifier
        # extra copy cards

        # TODO: Insert appropriate routing for copy cards routes here
        next_step = complete_copy_cards_path(@registration.uuid)
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

      # Check if renderType and orderCode exist, If so its okay to redirect to order page, If not render Expired page
      if session[:renderType] and session[:orderCode]
        next_step = upper_payment_path(@registration.uuid)
      else
        logger.info 'Cannot redirect to order page as session variables already removed, this assume, Retry failed.'
        renderAccessDenied and return
      end
    end

    if (session[:edit_mode].to_i  ==  RegistrationsController::EditMode::RECREATE) \
        || (session[:edit_mode].to_i  ==  RegistrationsController::EditMode::EDIT && \
            session[:edit_result].to_i  ==  RegistrationsController::EditResult::CREATE_NEW_REGISTRATION)
      if @registration.commit #create new reg
        original_reg = Registration[ session[:original_registration_id] ]
        @registration.set_inactive #deactivate existing reg
      else
        logger.error "Commit failed for registration id: #{@registration.id}"
        #TODO: error handlling
      end
    end

    logger.debug next_step.to_s
    logger.debug next_step.class.to_s

    if next_step == complete_edit_renew_path(@registration.uuid).to_s
      logger.debug "setting next step"
      next_step = complete_edit_renew_path(id: @registration.uuid, edit_mode: session[:edit_mode],
                                           edit_result: session[:edit_result])
      logger.debug next_step.to_s
      clear_edit_session # we don't need edit variables polluting the session any more
    end

    redirect_to next_step

  end

  def failure
    @registration = Registration.find_by_id(session[:registration_uuid])
    if process_payment
      # Should not get here as payment should have failed and thus return false
    else
      flash[:notice] = 'Your payment failed'
      redirect_to upper_payment_path(session[:registration_uuid])
    end
  end

  def pending
    #TODO - Process response and edirect...
    process_payment
  end

  def cancel
    @registration = Registration.find_by_id(session[:registration_uuid])
    if process_payment
      # should not get here as payment was cancelled
    else
      flash[:notice] = 'You have cancelled your payment'
      redirect_to upper_payment_path(session[:registration_uuid])
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

      # Update order to reflect failed payment status
      orderCode = orderKey.split('^').at(2)
      order = @registration.getOrder( orderCode)
      now = Time.now.utc.xmlschema
      order.dateLastUpdated = now
      order.worldPayStatus = 'VERIFICATIONFAILED'
      order.save! session[:registration_uuid]

      payment_processed = false
    elsif paymentStatus.eql? 'AUTHORISED'
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
        if @payment.save! session[:registration_uuid]
          #@payment.save(:validate => false)
          payment_processed = true
        end
      else
        logger.error 'Payment is not valid! ' + @payment.errors.messages.to_s
        payment_processed = false
        #TODO: what does this do? -need to replace it with explicit save
        @payment.save(:validate => false)
      end
    else
      orderCode = orderKey.split('^').at(2)
      logger.error 'Payment status was not successful, paymentStatus: ' + paymentStatus.to_s + " for order: " + orderCode.to_s

      # Update order to reflect failed payment status
      order = @registration.getOrder( orderCode)
      now = Time.now.utc.xmlschema
      order.dateLastUpdated = now
      order.worldPayStatus = paymentStatus
      order.save! session[:registration_uuid]

      payment_processed = false
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
        if session[:edit_mode]
          logger.debug "edited registration id: #{@registration.id}"

          # Check if a new registration is required, and create prior to deleting session variables
          if RegistrationsController::EditResult::CREATE_NEW_REGISTRATION.eql? session[:edit_result].to_i and !create_new_reg
            # redirect to previous page due to error
            logger.error "Failed to create new registration"
            # TODO: redirect to ??? because of failure?
            
          end

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
        @registration = Registration.find_by_id(session[:registration_uuid])
        logger.debug "#{@registration.id}"
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
