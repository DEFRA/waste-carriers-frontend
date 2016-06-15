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
    @order ||= Order.new

    @renderType = session[:renderType]
    renderNotFound && return unless @order.isValidRenderType?(@renderType)

    setup_registration('payment', true)

    renderNotFound && return unless @registration

    @registration.copy_cards ||= 0
    @registration.update(copy_card_only_order: 'yes') if Order.extra_copycards_identifier == @renderType

    @registration.order_builder.current_user = current_user || current_agency_user
    @registration.registration_fee = @registration.order_builder.registration_fee
    @registration.total_fee = @registration.order_builder.total_fee
  end

  # POST /create
  def create
    setup_registration 'payment'

    @registration.copy_cards ||= 0
    @registration.order_builder.current_user = current_user || current_agency_user

    # HERE is the place where we determine whether we need to update an order
    # that already exists against the registration (and is in the database),
    # or create a new one.
    if @registration.order_builder.indicates_new_registration?
      # This order is for the initial registration, and has already been
      # committed to the database at the time the registration was written.
      # Therefore we need to update the existing order.
      new_order_code = @registration.finance_details.first.orders.first.orderCode
    elsif session.has_key?(:orderCode)
      # The user has returned to this page by cancelling in Worldpay, or via
      # using the back button.  To avoid creating a duplicate order, we re-use
      # the last order-code.
      new_order_code = session[:orderCode]
    else
      # This must be a new order; we'll let the Order Builder generate a new
      # order code.
      new_order_code = nil
    end

    # Generate the new order, and store its key in the session, so that we can
    # handle the case where a user Cancels in Worldpay or uses the browser
    # back button.
    @order = @registration.order_builder.order(new_order_code)
    session[:orderCode] = @order.orderCode

    unless @registration.valid? && @order.valid?
      logger.debug "registration validation errors: #{@registration.errors.messages.to_s}"
      logger.debug "order validation errors: #{@registration.errors.messages.to_s}"
      render 'new', status: '400'
      return
    end

    # Does the session order with orderCode exist already?
    existing_order = @registration.getOrder(session[:orderCode])
    if existing_order.present?
      # We must update the newly-generated order to contain the ID of the existing
      # order, as this is how the services decides which order to overwrite.
      @order.orderId = existing_order.orderId
      @order.save!(@registration.uuid)
    else
      @order.commit(@registration.uuid)
    end

    # Re-get registration from the database to update the local redis version
    @registration = Registration.find_by_id(@registration.uuid)
    unless @registration.save
      @order.errors.add(:exception, @order.exception.to_s)
      logger.warn 'The update order was not saved to services.'
      render 'new', status: '400'
      return
    end

    logger.debug "About to redirect to Worldpay or Offline payment"
    set_google_analytics_payment_indicator(session, @order)

    if @order.paymentMethod == 'OFFLINE'
      logger.debug "The registration is valid - redirecting to Offline payment page..."
      redirect_to newOfflinePayment_path(orderCode: @order.orderCode )
    else
      logger.debug "The registration is valid - redirecting to Worldpay..."
      response = send_xml(create_xml(@registration, @order))
      render('new', status: '400') && return unless response
      redirect_to get_redirect_url(parse_xml(response.body))
    end

  end

end
