class OrderController < ApplicationController
  include OrderHelper
  include WorldpayHelper
  include RegistrationsHelper

  # GET /index
  def index
    # does nothing
  end

  # GET /new
  def new
    # Setup registration.
    setup_registration('payment', true)
    unless @registration
      logger.error {'OrderController::new: No @registration; cannot continue.'}
      renderNotFound
      return
    end

    # If the order is for anything other than additional Copy Cards, then it
    # should have already been created and added to the registration.  Otherwise
    # we create a new (blank) order here, so that it only gets committed if the
    # user actually goes ahead with their order.
    @renderType = session[:renderType]
    if @renderType.eql?(Order.extra_copycards_identifier)
      @order ||= Order.new
      @registration.update(copy_card_only_order: 'yes')
      if !@registration.copy_cards || (@registration.copy_cards.to_i < 1)
        @registration.copy_cards = 1
      end
    else
      @registration.update(copy_card_only_order: nil)
      @registration.copy_cards = 0 unless @registration.copy_cards

      # Check we have an Order Code.
      unless session.key?(:orderCode)
        logger.error {'OrderController::new: No orderCode in session; cannot continue.'}
        renderNotFound
        return
      end

      # Setup order.
      @order = @registration.getOrder(session[:orderCode])
      unless @order
        logger.error {'OrderController::new: No @order; cannot continue.'}
        renderNotFound
        return
      end

      # Confirm the Render Type is valid.
      unless @order.isValidRenderType?(@renderType)
        logger.error {'OrderController::new: Invalid renderType; cannot continue.'}
        renderNotFound
        return
      end
    end

    # Calculate fees shown on page
    calculate_fees(@registration, @renderType)
  end

  # POST /create
  def create
    # Setup registration and get Render Type.
    setup_registration('payment')
    @renderType = session[:renderType]

    # Validate the registration.
    unless @registration.valid?
      logger.error {'OrderController::create: @registration is not valid: ' + my_registration.errors.messages.to_s}
      render 'new', :status => '400'
      return
    end
    
    # Determine what type of payment is chosen, and update the order accordingly.
    bank_transfer = (@registration.payment_type === "bank_transfer")
    @order = prepareGenericOrder(@registration, @renderType, session[:orderId], session[:orderCode])
    if bank_transfer
      updateOrderForOffline(@order, @registration)
    else
      updateOrderForWorldpay(@order, @registration)
    end

    # Depending upon the Render Type, we may want to clear fee-related fields
    # on the registration, and save it to Redis and Mongo.
    unless @renderType.eql?(Order.new_registration_identifier) ||
           @renderType.eql?(Order.editrenew_caused_new_identifier) ||
           isIRRenewal?(@registration, @renderType)

      @registration.total_fee = nil
      @registration.registration_fee = nil
      @registration.copy_card_fee = nil
      @registration.copy_cards = nil

      if @registration.save!  # Save to Mongo
        @registration.save    # Save to Redis
      else
        logger.error {'Failed to save registration prior to updating the order'}
        my_order.errors.add(:exception, @registration.exception.to_s)
        render 'new', :status => '400'
        return
      end
    end

    # Add the order to the registration, then redirect to the next page.
    if @renderType.eql?(Order.extra_copycards_identifier) && !@registration.hasOrder?(session[:orderCode])
      order_saved = add_new_order_to_registration(@registration, @order, skip_registration_validation: true)
    else
      order_saved = update_order_on_registration(@registration, @order)
    end

    unless order_saved
      render 'new', :status => '400'
      return
    else
      logger.info {'Order saved.  About to redirect to Worldpay/Offline payment.'}
      set_google_analytics_payment_indicator(session, @order)

      if bank_transfer
        redirect_to newOfflinePayment_path(orderCode: @order.orderCode)
      else
        response = send_xml(create_xml(@registration, @order))
        unless response
          render 'new', :status => '400'
          return
        end
        redirect_to get_redirect_url(parse_xml(response.body))
      end
    end

  end

end
