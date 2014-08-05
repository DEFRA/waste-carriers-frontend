class PaymentController < ApplicationController

  include WorldpayHelper

  before_filter :authenticate_agency_user!

  # GET /payments
  def new
    @registration = Registration.find_by_id(params[:id])
    @payment = Payment.find_by_registration(params[:id])

    # Override amount to be empty as payment object from services will return an amount of 0
    if @payment.amount == 0
      @payment.amount = ''
    end

    # If dateReceived is empty reset split up values
    unless @payment.dateReceived
      @payment.dateReceived_day = ''
      @payment.dateReceived_month = ''
      @payment.dateReceived_year = ''
      logger.info 'set date received manually'
    end

    authorize! :read, @registration
    authorize! :enterPayment, @payment
  end

  # POST /payments
  def create
    logger.info 'create request has been made'
    # Get a new payment object from the parameters in the post
    @payment = Payment.new(params[:payment])
    authorize! :enterPayment, @payment

    # Manually set date, as it is saved as a single value in the DB, but 3 values in the rails
    @payment.dateReceived = params[:payment][:dateReceived_day]+'/'+params[:payment][:dateReceived_month]+'/'+params[:payment][:dateReceived_year]

    # Add user id of user who made the payment to the payment record
    @payment.updatedByUser = current_agency_user.id.to_s

	# Set override to validate amount as pounds as came from user screen in pounds not in pence from Worldpay
	@payment.manualPayment = true

	if @payment.valid?
	  logger.info 'payment is valid'
    puts @payment.to_json
	  @payment.save! params[:id]

	  # Redirect user back to payment status
      redirect_to paymentstatus_path, alert: "Payment has been successfully entered."
	else
	  logger.info 'payment is invalid'

	  # Need to re-get the registration information as it was not re-posted, but we can reuse the payment information
      @registration = Registration.find_by_id(params[:id])
      authorize! :read, @registration

	  # Need to also re-populate split dateRecieved parameters
	  @payment.dateReceived_day = params[:payment][:dateReceived_day]
      @payment.dateReceived_month = params[:payment][:dateReceived_month]
      @payment.dateReceived_year = params[:payment][:dateReceived_year]

      render "new", :status => '400'
	end
  end

  # GET /writeOffs
  def newWriteOff
    @registration = Registration.find_by_id(params[:id])
    @payment = Payment.find_by_registration(params[:id])

    isFinanceAdmin = current_agency_user.has_role? :Role_financeAdmin, AgencyUser

    if isFinanceAdmin
      # do finance admin write off
      # Redirect to paymentstatus is balance is negative or paid
      logger.info 'balance: ' + @registration.finance_details.first.balance.to_s
      isLargeMessage = Payment.isLargeWriteOff( @registration.finance_details.first.balance)
      if isLargeMessage == true
        logger.info 'Balance is in range for a large write off'
        # Set fixed Amount at exactly negative outstanding balance
        @payment.amount = @registration.finance_details.first.balance.to_f.abs
      else
        logger.info 'Balance is out of range for a large write off'
        redirect_to :paymentstatus, :alert => isLargeMessage
      end
    else
      # Redirect to paymentstatus is balance is negative or paid
      if @registration.finance_details.first
        logger.info 'balance: ' + @registration.finance_details.first.balance.to_s
        isSmallMessage = Payment.isSmallWriteOff( @registration.finance_details.first.balance)
        if isSmallMessage == true
          logger.info 'Balance is in range for a small write off'
          # Set fixed Amount at exactly negative outstanding balance
        @payment.amount = @registration.finance_details.first.balance.to_f.abs
        else
          logger.info 'Balance is out of range for a small write off'
          redirect_to :paymentstatus, :alert => isSmallMessage
        end
      else
        logger.info 'Balance is not available'
        redirect_to :paymentstatus, :alert => I18n.t('payment.newWriteOff.writeOffNotAppropriate')
      end
    end

    authorize! :read, @registration
    authorize! :writeOffPayment, @payment
  end

  # POST /writeOffs
  def createWriteOff
    logger.info 'createWriteOff request has been made'
    # Get a new payment object from the parameters in the post
    @payment = Payment.new(params[:payment])
    authorize! :writeOffPayment, @payment

    # Set fields automatically for write off's
    @payment.dateReceived = Time.new.strftime("%Y-%m-%d")
    @payment.updatedByUser = current_agency_user.id.to_s
    @payment.paymentType = 'WRITEOFFSMALL'


	# Set override to validate amount as pounds as came from user screen and was converted to display as pounds
	@payment.manualPayment = true

	if @payment.valid?
	  logger.info 'writeOff is valid'
	  @payment.save! params[:id]

	  # Redirect user back to payment status
      redirect_to paymentstatus_path, alert: "Payment has been successfully entered."
	else
	  logger.info 'writeOff is invalid'

	  # Need to re-get the registration information as it was not re-posted, but we can reuse the payment information
      @registration = Registration.find_by_id(params[:id])
      authorize! :read, @registration

      render "newWriteOff", :status => '400'
	end
  end

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

  # GET /manualRefund
  def manualRefund

    #
    # TODO: Use order code value to create a negative payment of the amount requested in the order
    #

  end

  # GET /worldpayRefund/:orderCode
  def newWPRefund
    logger.info 'Request to worldpayRefund'
    @registration = Registration.find_by_id(params[:id])
    @orderCode = params[:orderCode]

	# Get payment from registration
    @payment = Payment.getPayment(@registration, params[:orderCode])

    authorize! :read, @registration
  end

  # POST /worldpayRefund/:orderCode
  def createWPRefund
    logger.info 'Request to createWorldpay, id:' + params[:id] + ' orderCode:' + params[:orderCode]

    #
    # TODO: Use order code value to create a negative payment of the amount requested in the order
    #

	# Get selected payment from registration by order code
	@registration = Registration.find_by_id(params[:id])
	@foundPayment = Payment.getPayment(@registration, params[:orderCode])
	@payment = Payment.new(@foundPayment.attributes)
	logger.info 'found payment:' + @foundPayment.attributes.to_s

	# Flip the value of the selected payment to be a negative payment, ie a refund
	@payment.amount = -@payment.amount.to_i.abs
	logger.info 'payment amount:' + @payment.amount.to_s

	# Set automatic Payment values
	@payment.paymentType = 'WORLDPAY REFUND'
	@payment.dateReceived = Date.current
    @payment.updatedByUser = current_agency_user.id.to_s
    
    # This makes the payment a refund by updating the orderCode to include a refund postfix
    @payment.makeRefund

	if @payment.valid?
	  logger.info 'payment is valid'
	  
	  # Make request to worldpay
	  response = request_refund_from_worldpay(params[:orderCode], @payment.amount )
	  
	  # Check if response from worldpay contains ok message
	  if responseOk?(response)
	    
	    # Save refund payment
	    @payment.save! params[:id]
	    
	    # Force a redirect to worldpayRefund, so that a get request on this URL wil not be caused by a refresh
        redirect_to ({ action: 'completeWPRefund', id: params[:id], orderCode: params[:orderCode] })
	  else
	    logger.info 'Failed request from WP'
	    
	    # Reset payment to payment from db
	    @payment = @foundPayment
	    
	    # Add refund request failed from WP error
	    @payment.errors.add(:worldPayPaymentStatus, I18n.t('errors.messages.worldpayFailed'))
	    
	    render "newWPRefund", :status => '400'
	  end
	else
	  logger.info 'payment is not valid'
	  if @payment.errors.any?
	    logger.info 'has errors'
	    @payment.errors.each do |error|
	      logger.info 'error: ' + error.to_s
	    end
	  else
	    logger.info 'no errors???'
	  end

	  render "newWPRefund", :status => '400'
	end


  end

  # GET /worldpayRefund/:orderCode/refundComplete
  def completeWPRefund
    logger.info 'Request to worldpayRefund'
    @registration = Registration.find_by_id(params[:id])
    @orderCode = params[:orderCode]

    authorize! :read, @registration
  end

end
