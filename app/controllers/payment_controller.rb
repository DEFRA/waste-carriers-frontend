class PaymentController < ApplicationController

  include WorldpayHelper
  include PaymentsHelper

  before_filter :authenticate_agency_user!

  #####################################################################################
  # Payments
  #####################################################################################

  # GET /payments
  def new
    @registration = Registration.find_by_id(params[:id])
    @payment = Payment.create

    # Override amount to be empty as payment object from services will return an amount of 0
    if @payment.amount == 0
      @payment.amount = ''
    end

    # If dateReceived is empty reset split up values
    unless @payment.dateReceived
      @payment.dateReceived_day = ''
      @payment.dateReceived_month = ''
      @payment.dateReceived_year = ''
      logger.debug 'set date received manually'
    end

    authorize! :read, @registration
    authorize! :enterPayment, @payment
  end

  # POST /payments
  def create
    logger.debug 'create request has been made'
    # Need to re-get the registration information as it was not re-posted
    @registration = Registration.find_by_id(params[:id])
    authorize! :read, @registration
    # Get a new payment object from the parameters in the post
    @payment = Payment.init(params[:payment])
    authorize! :enterPayment, @payment

    # Manually set date, as it is saved as a single value in the DB, but 3 values in the rails
    @payment.dateReceived = params[:payment][:dateReceived_day]+'/'+params[:payment][:dateReceived_month]+'/'+params[:payment][:dateReceived_year]

    # Add email of user who made the payment to the payment record
    @payment.updatedByUser = current_agency_user.email

    # Manually set the orderkey of the payment to a new orderkey as it needs a key to be reversed.
    @payment.orderKey = generateOrderCode

    # Ensure currency set
    @payment.currency = getDefaultCurrency

    # Set override to validate amount as pounds as came from user screen in pounds not in pence from Worldpay
	  @payment.manualPayment = true

    # Check the payment type for a reversal payment type, If found negate the amount
    @payment.negateAmount

	if @payment.valid?
	  logger.debug 'payment is valid'
	  if @payment.save! params[:id]
	    # Payment successful, Now need to check if registration activated?

	    # Get updated registration
	    updatedRegistration = Registration.find_by_id(params[:id])

	    # If registration has been activated
	    if wasActivated(@registration, updatedRegistration)
	      logger.debug 'About to send email because payment received'

	      # Send welcome email
	      user = User.find_by_email(@registration.accountEmail)
	      Registration.send_registered_email(user, updatedRegistration)
	      logger.debug 'Registration email sent'
	    end

	    # Redirect user back to payment status
        redirect_to paymentstatus_path, alert: I18n.t('registrations.form.paymentSuccessful')
        return
      end
	end

	logger.debug 'payment is invalid'

	# add any payment errors if server side error
	if !@payment.exception.nil?
	  @payment.errors.add(:exception, @payment.exception.to_s)
	end

	# Need to also re-populate split dateRecieved parameters when rerendering page
	@payment.dateReceived_day = params[:payment][:dateReceived_day]
    @payment.dateReceived_month = params[:payment][:dateReceived_month]
    @payment.dateReceived_year = params[:payment][:dateReceived_year]

    render "new", status: :bad_request
  end

  #####################################################################################
  # Write Off
  #####################################################################################

  # GET /writeOffs
  def newWriteOff
    @registration = Registration.find_by_id(params[:id])
    @payment = Payment.create
    #Payment.find_by_registration(params[:id])
    @type = 'default'

    isFinanceAdmin = current_agency_user.has_role? :Role_financeAdmin, AgencyUser
    isAgencyRefundPayment = current_agency_user.has_role? :Role_agencyRefundPayment, AgencyUser

    if params[:type] == 'writeOffLarge' and isFinanceAdmin
      logger.debug 'LARGE WRITE OFF SELECTED'
      @type = 'writeOffLarge'
      # do finance admin write off
      # Redirect to paymentstatus is balance is negative or paid
      logger.debug 'balance: ' + @registration.finance_details.first.balance.to_s
      isLargeMessage = Payment.isLargeWriteOff( @registration.finance_details.first.balance)
      if isLargeMessage == true
        logger.debug 'Balance is in range for a large write off'
        # Set fixed Amount at exactly negative outstanding balance
        @payment.amount = @registration.finance_details.first.balance.to_f.abs
      else
        logger.debug 'Balance is out of range for a large write off'
        redirect_to :paymentstatus, :alert => isLargeMessage
      end
      authorize! :writeOffLargePayment, @payment
    elsif params[:type] == 'writeOffSmall' and isAgencyRefundPayment
      logger.debug 'SMALL WRITE OFF SELECTED'
      @type = 'writeOffSmall'
      # Redirect to paymentstatus is balance is negative or paid
      if @registration.finance_details.first
        logger.debug 'balance: ' + @registration.finance_details.first.balance.to_s
        isSmallMessage = Payment.isSmallWriteOff( @registration.finance_details.first.balance)
        if isSmallMessage == true
          logger.debug 'Balance is in range for a small write off'
          # Set fixed Amount at exactly negative outstanding balance
          @payment.amount = @registration.finance_details.first.balance.to_f.abs
        else
          logger.debug 'Balance is out of range for a small write off'
          redirect_to :paymentstatus, :alert => isSmallMessage
        end
      else
        logger.debug 'Balance is not available'
        redirect_to :paymentstatus, :alert => I18n.t('payment.newWriteOff.writeOffNotAppropriate')
      end
      authorize! :writeOffSmallPayment, @payment
    else
      message = 'Write off type incorrect'
      logger.debug message
      redirect_to :paymentstatus, :alert => I18n.t('payment.newWriteOff.writeOffTypeIncorrect')
      return
    end

    authorize! :read, @registration
  end

  # POST /writeOffs
  def createWriteOff
    logger.debug 'createWriteOff request has been made'

    @registration = Registration.find_by_id(params[:id])
    # Get a new payment object from the parameters in the post
    @payment = Payment.init(params[:payment])

    if params[:writeOffSmall] == I18n.t('registrations.form.writeoff_button_label')
      logger.debug 'Write off small'
      @type = 'writeOffSmall'
      @payment.paymentType = 'WRITEOFFSMALL'
      @payment.registrationReference = 'WRITEOFFSMALL'
      authorize! :writeOffSmallPayment, @payment
    elsif params[:writeOffLarge] == I18n.t('registrations.form.writeoff_button_label')
      logger.debug 'Write off large'
      @type = 'writeOffLarge'
      @payment.paymentType = 'WRITEOFFLARGE'
      @payment.registrationReference = 'WRITEOFFLARGE'
      authorize! :writeOffLargePayment, @payment
    else
      logger.debug 'Unrecognised write off button, sending back to newWriteoff page'
      message = 'Write off type incorrect'
      logger.debug message
      redirect_to :paymentstatus, :alert => I18n.t('payment.newWriteOff.writeOffTypeIncorrect')
      return
    end

    # Set payment amount to match outstanding balance
    @payment.amount = @registration.finance_details.first.balance.to_i

    # Ensure currency set
    @payment.currency = getDefaultCurrency

    # Set fields automatically for write off's
    @payment.dateReceived = Time.new.strftime("%Y-%m-%d")
    @payment.updatedByUser = current_agency_user.email

    @payment.orderKey = generateOrderCode

	# Set override to validate amount as pounds as came from user screen and was converted to display as pounds
	@payment.manualPayment = false

	if @payment.valid?
	  logger.debug 'writeOff is valid'
	  if @payment.save! params[:id]
	    # Get updated registration
	    updatedRegistration = Registration.find_by_id(params[:id])

	    # If registration has been activated
	    if wasActivated(@registration, updatedRegistration)
	      logger.debug 'About to send email because writeoff received'

	      # Send welcome email
	      user = User.find_by_email(@registration.accountEmail)
	      Registration.send_registered_email(user, updatedRegistration)
	      logger.debug 'Registration email sent'
	    end

	    # Redirect user back to payment status
        redirect_to paymentstatus_path, alert: I18n.t('payment.newWriteOff.writeOffSuccessful')
        return
	  end
	end

	logger.debug 'writeOff is invalid'
	if @payment.errors.any?
	  @payment.errors.each do |error|
	    logger.debug 'write off error: ' + error.to_s
	  end
	end

    authorize! :read, @registration

    # Revert payment amount to outstanding balance
    @payment.amount = @registration.finance_details.first.balance.to_f.abs

    render "newWriteOff", status: :bad_request
  end

  #####################################################################################
  # Refunds
  #####################################################################################

  # GET /refunds
  def index
	@registration = Registration.find_by_id(params[:id])

    authorize! :read, @registration

    #
    # TODO: Change this if not appropriate, if we are listing the orders, or manipulating them later?
    #
    authorize! :newRefund, Payment

  end

  # POST /refunds
  def createRefund

    authorize! :newRefund, Payment
  end

  # GET /manualRefund/:orderCode
  def manualRefund

    logger.debug 'Request to manualRefund'
    @registration = Registration.find_by_id(params[:id])
    @orderCode = params[:orderCode]

	# Get payment from registration
    @payment = Payment.getPayment(@registration, params[:orderCode])

    #
    # TODO: Use order code value to create a negative payment of the amount requested in the order
    #
    authorize! :newRefund, Payment
  end

  # POST /manualRefund/:orderCode
  def createManualRefund
    logger.debug 'Request to createManualRefund'

	# Get selected payment from registration by order code
	@registration = Registration.find_by_id(params[:id])
	@foundPayment = Payment.getPayment(@registration, params[:orderCode])
	@payment = Payment.new(@foundPayment.attributes)
	logger.debug 'found payment:'

	# Set the amount of the payment to be a negative payment, ie a refund from the balance due
	@payment.amount = -getMaxRefundAmount(@registration, @foundPayment)
	logger.debug 'payment amount:' + @payment.amount.to_s

	# Ensure currency set
    @payment.currency = getDefaultCurrency

    now = Time.now.utc.xmlschema
	# Set automatic Payment values
	@payment.paymentType = 'REFUND'
	@payment.dateReceived = now
    @payment.updatedByUser = current_agency_user.email
    @payment.comment = 'A manual refund has been requested for this payment'

    # This makes the payment a refund by updating the orderCode to include a refund postfix
    @payment.makeRefund

	if @payment.valid?
	  logger.debug 'payment is valid'

	  # Save refund payment
	  @payment.save! params[:id]

	  # Force a redirect to completeRefund, so that a get request on this URL wil not be caused by a refresh
      redirect_to ({ action: 'completeRefund', id: params[:id], orderCode: params[:orderCode] })
	else
	  logger.debug 'payment is not valid'
	  if @payment.errors.any?
	    logger.debug 'has errors'
	    @payment.errors.each do |error|
	      logger.debug 'error: ' + error.to_s
	    end
	  end

	  render "manualRefund", status: :bad_request
	end

	authorize! :read, @registration
	#
    # TODO: Change this if not appropriate, if we are listing the orders, or manipulating them later?
    #
    authorize! :newRefund, Payment

  end

  # GET /worldpayRefund/:orderCode
  def newWPRefund
    logger.debug 'Request to worldpayRefund'
    @registration = Registration.find_by_id(params[:id])
    @orderCode = params[:orderCode]

	# Get payment from registration
    @payment = Payment.getPayment(@registration, params[:orderCode])

    authorize! :read, @registration

    #
    # TODO: Change this if not appropriate, if we are listing the orders, or manipulating them later?
    #
    authorize! :newRefund, Payment
  end

  # POST /worldpayRefund/:orderCode
  def createWPRefund
    logger.debug 'Request to createWorldpay'

    #
    # TODO: Use order code value to create a negative payment of the amount requested in the order
    #

	# Get selected payment from registration by order code
	@registration = Registration.find_by_id(params[:id])
	@foundPayment = Payment.getPayment(@registration, params[:orderCode])
	@payment = Payment.new(@foundPayment.attributes)
	logger.debug 'found payment'

	# Set the amount of the payment to be a negative payment, ie a refund from the balance due
	@payment.amount = -getMaxRefundAmount(@registration, @foundPayment)
	logger.debug 'payment amount:' + @payment.amount.to_s

	# Ensure currency set
    @payment.currency = getDefaultCurrency

    now = Time.now.utc.xmlschema
	# Set automatic Payment values
	@payment.paymentType = 'REFUND'
	@payment.dateReceived = now
    @payment.updatedByUser = current_agency_user.email
    @payment.comment = I18n.t('registrations.form.refund_request')

    # This makes the payment a refund by updating the orderCode to include a refund postfix
    @payment.makeRefund

	if @payment.valid?
	  logger.debug 'payment is valid'

	  # Find original order from registration
	  order = Order.getOrder(@registration, params[:orderCode])
	  logger.debug 'Merchant Id found from original order: ' + order.merchantId

	  # Make request to worldpay
	  response = request_refund_from_worldpay(params[:orderCode], order.merchantId, @payment.amount.to_i.abs )

	  # Check if response from worldpay contains ok message
	  if responseOk?(response)

	    # Save refund payment
	    @payment.save! params[:id]

	    # Force a redirect to worldpayRefund, so that a get request on this URL wil not be caused by a refresh
        redirect_to ({ action: 'completeRefund', id: params[:id], orderCode: params[:orderCode] })
	  else
	    logger.debug 'Failed request from WP'

	    # Reset payment to payment from db
	    @payment = @foundPayment

	    # Add refund request failed from WP error
	    @payment.errors.add(:worldPayPaymentStatus, I18n.t('errors.messages.worldpayFailed'))

	    render "newWPRefund", status: :bad_request
	  end
	else
	  logger.debug 'payment is not valid'
	  if @payment.errors.any?
	    logger.debug 'has errors'
	    @payment.errors.each do |error|
	      logger.debug 'error: ' + error.to_s
	    end
	  end

	  render "newWPRefund", status: :bad_request
	end

	authorize! :read, @registration
	#
    # TODO: Change this if not appropriate, if we are listing the orders, or manipulating them later?
    #
    authorize! :newRefund, Payment

  end

  # GET /worldpayRefund/:orderCode/retry
  def retryWPRefundRequest
    # Get selected payment from registration by order code
	registration = Registration.find_by_id(params[:id])
	foundPayment = Payment.getPayment(registration, params[:orderCode])

	# Get order code from payment key
	originalOrderCode = foundPayment.orderKey
    if foundPayment.orderKey.include? "_"
       originalOrderCode = originalOrderCode.split("_")[0]
    end

    # Get original order (to get merchant ID)
    order = Order.getOrder(registration, originalOrderCode)

	# authorise request
	authorize! :read, registration
	authorize! :newRefund, Payment

	# Make request to worldpay
	response = request_refund_from_worldpay(originalOrderCode, order.merchantId, foundPayment.amount.to_i.abs )

	# Check if response from worldpay contains ok message
	if responseOk?(response)
	  # Redirect user back to payment status
      redirect_to paymentstatus_path, alert: I18n.t('payment.newWPRefund.requestReAttempted')
	else
	  # Worldpay refund retry request failed
      redirect_to paymentstatus_path, alert: I18n.t('payment.newWPRefund.reAttemptHas') + " " + I18n.t('errors.messages.worldpayFailed')
	end
  end

  # GET /refund/:orderCode/refundComplete
  def completeRefund
    logger.debug 'Request to worldpayRefund'
    @registration = Registration.find_by_id(params[:id])
    @orderCode = params[:orderCode]

    authorize! :read, @registration

    authorize! :newRefund, Payment
  end

  #####################################################################################
  # Charge Adjustments
  #####################################################################################

  # GET /chargeAdjustments
  def chargeIndex
    @registration = Registration.find_by_id(params[:id])

    authorize! :read, @registration

    #
    # TODO: Change this if not appropriate, if we are listing the orders, or manipulating them later?
    #
    authorize! :newAdjustment, Order
  end

  # POST /chargeAdjustments
  def selectAdjustment
    @registration = Registration.find_by_id(params[:id])
    authorize! :read, @registration

    if params[:positive_payment] == I18n.t('registrations.form.chargePositive_button_label')
      logger.debug 'Positive Order entry requested'
      redirect_to newAdjustment_path(:orderType => Order.getPositiveType )
    elsif params[:negative_payment] == I18n.t('registrations.form.chargeNegative_button_label')
      logger.debug 'Negative Order entry requested'
      redirect_to newAdjustment_path(:orderType => Order.getNegativeType )
    else
      logger.debug 'Unrecognised button found, sending back to chargeIndex page'
      render 'chargeIndex'
    end

    #
    # TODO: Change this if not appropriate, if we are listing the orders, or manipulating them later?
    #
    authorize! :newAdjustment, Order
  end

  # GET /newAdjustment
  def newAdjustment
    logger.debug 'orderType:' + params[:orderType]

    @order = Order.create
    @order.amountType = params[:orderType]
    @order.orderId = SecureRandom.uuid

    #
    # TODO: Change this if not appropriate, if we are listing the orders, or manipulating them later?
    #
    authorize! :newAdjustment, Order
  end

  # POST /newAdjustment
  def createAdjustment
    @order = Order.init(params[:order])

    # Generate default adjustment details
    @order.orderCode = generateOrderCode
    @order.merchantId = 'n/a'
    @order.paymentMethod = 'UNKNOWN'
    @order.currency = getDefaultCurrency
    @order.updatedByUser = current_agency_user.email
    now = Time.now.utc.xmlschema
    @order.dateCreated = now
    @order.dateLastUpdated = now

    theAmount = 0
    begin
      theAmount = Float(@order.totalAmount)
    rescue => e
      notify_airbrake(e)
      logger.debug 'Couldnt convert to float: ' + e.to_s
    end

    # Create Order Item
    orderItem = OrderItem.new
    orderItem.amount = (theAmount*100).to_i

    if params[:positiveAdjustment] == I18n.t('registrations.form.enteradjustment_button_label')
      # positive
      @order.amountType = Order.getPositiveType
      @orderType = Order.getPositiveType
    elsif params[:negativeAdjustment] == I18n.t('registrations.form.enteradjustment_button_label')
      # negative
      @order.amountType = Order.getNegativeType
      @orderType = Order.getNegativeType
      orderItem.amount = -orderItem.amount
    else
      # neither
      @order.amountType = 'default'
      @order.errors.add(:amountType, I18n.t('errors.messages.invalid_selection'))
    end

    orderItem.currency = 'GBP'
    orderItem.description = @order.description
    # Use a temporary field in the form view 'order_item_reference' to contain the information needed for this order item
    orderItem.reference = params[:order][:order_item_reference]
    orderItem.type = OrderItem::ORDERITEM_TYPES[5]
    orderItem.save
    @order.order_items.add orderItem

    # Set to manual order (amount entered in pounds to pence)
    @order.manualOrder = true

    # validate orderType
    if @order.includesOrderType? @order.amountType
      if @order.valid?

        # Get original registration
        originalRegistration = Registration.find_by_id(params[:id])

        # save
        if @order.commit params[:id]

          # Get updated registration
	      updatedRegistration = Registration.find_by_id(params[:id])

	      # If registration has been activated
	      if wasActivated(originalRegistration, updatedRegistration)
	        logger.debug 'About to send email because writeoff received'

	        # Send welcome email
	        user = User.find_by_email(originalRegistration.accountEmail)
	        Registration.send_registered_email(user, updatedRegistration)
	        logger.debug 'Registration email sent'
	      end

          # Redirect user back to payment status
          redirect_to paymentstatus_path, alert: I18n.t('payment.createAdjustment.success')
          return
        else
          @order.errors.add(:exception, @order.exception.to_s)
        end
      end
    else
      @order.errors.add(:amountType, I18n.t('errors.messages.invalid_selection'))
    end

    # Return to entry page, as errors must have occured
    render "newAdjustment", status: :bad_request

    #
    # TODO: Change this if not appropriate, if we are listing the orders, or manipulating them later?
    #
    authorize! :newAdjustment, Order

  end

  #####################################################################################
  # Reversals
  #####################################################################################

  # GET /paymentReversals
  def reversalIndex
    @registration = Registration.find_by_id(params[:id])

    authorize! :read, @registration

    #
    # TODO: Change this if not appropriate, if we are listing the orders, or manipulating them later?
    #
    authorize! :newReversal, Payment
  end

  # GET /newReversal
  def newReversal
    @registration = Registration.find_by_id(params[:id])
    @payment = Payment.create
    #find_by_registration(params[:id])

    # Update the payment to include a reference to the payment being reverse, and mark this as a reversal or said payment
    #@payment.orderKey = params[:orderCode] + '_REVERSAL'

    originalPayment = Payment.getPayment(@registration, params[:orderCode])
    @payment.amount = originalPayment.amount

    # If dateReceived is empty reset split up values
    unless @payment.dateReceived
      @payment.dateReceived_day = ''
      @payment.dateReceived_month = ''
      @payment.dateReceived_year = ''
      logger.debug 'set date received manually'
    end

    authorize! :read, @registration

    #
    # TODO: Change this if not appropriate, if we are listing the orders, or manipulating them later?
    #
    authorize! :newReversal, Payment
  end

  # POST /newReversal
  def createReversal

    @registration = Registration.find_by_id(params[:id])

    # TODO : Implement the create payment from the reversal details entered
    @payment = Payment.init(params[:payment])

    # Setup fields automatically for reversal
    @payment.dateReceived = Time.new.strftime("%Y-%m-%d")
    @payment.updatedByUser = current_agency_user.email
    @payment.paymentType = 'REVERSAL'

    # Update the payment to include a reference to the payment being reverse, and mark this as a reversal or said payment
    @payment.orderKey = params[:orderCode] + '_REVERSAL'

	originalPayment = Payment.getPayment(@registration, params[:orderCode])
    @payment.amount = originalPayment.amount

    # Ensure currency set
    @payment.currency = getDefaultCurrency

    @payment.registrationReference = originalPayment.registrationReference

	# Save original amount
    originalAmount = @payment.amount

    # Set override to validate amount as pounds as came from user screen and was converted to display as pounds
	@payment.manualPayment = false

    # Negate payment for reversals
    @payment.negateAmount

    logger.debug 'amount after negation: ' + @payment.amount.to_s

    logger.debug 'Is manual payment: ' + @payment.isManualPayment?.to_s

    if @payment.valid?
      @payment.save! @registration.uuid
      redirect_to :paymentstatus, :flash => { :alert => I18n.t('payment.newReversal.success') }
      return
    end

    # Re-populate the original payment
    @payment.amount = originalAmount

    logger.debug 'amount after revert: ' + @payment.amount.to_s

    # Return to entry page, as errors must have occured
    render "newReversal", status: :bad_request

    #
    # TODO: Change this if not appropriate, if we are listing the orders, or manipulating them later?
    #
    authorize! :newReversal, Payment
  end

end
