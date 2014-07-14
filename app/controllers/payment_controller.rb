class PaymentController < ApplicationController

  before_filter :authenticate_agency_user!

  # GET /payments
  def new
    @registration = Registration.find(params[:id])
    @payment = Payment.find(:one, :from => "/registrations/"+params[:id]+"/payments/new.json")
    
    # Override amount to be empty as payment object from services will return an amount of 0
    if @payment.amount == 0
      @payment.amount = ''
    end
    
    # If dateReceived is empty reset split up values
    if @payment.dateReceived.nil?
      @payment.dateReceived_day = ''
      @payment.dateReceived_month = ''
      @payment.dateReceived_year = ''
      logger.info 'set date recieved manually'
    end
    
    authorize! :read, @registration
    authorize! :update, @payment
  end
  
  # POST /payments
  def create
    logger.info 'create request has been made'
    # Get a new payment object from the parameters in the post
    @payment = Payment.new(params[:payment])
    
    # Manually set date, as it is saved as a single value in the DB, but 3 values in the rails
    @payment.dateReceived = params[:payment][:dateReceived_day]+'/'+params[:payment][:dateReceived_month]+'/'+params[:payment][:dateReceived_year]
    
    # Add user id of user who made the payment to the payment record
    @payment.updatedByUser = current_agency_user.id.to_s

    # Add registration Id as a prefix option
	@payment.prefix_options[:id] = params[:id]
	
	if @payment.valid?
	  logger.info 'payment is valid'
	  @payment.save!
	  
	  # Redirect user back to payment status
      redirect_to paymentstatus_path, alert: "Payment has been successfully entered."
	else
	  logger.info 'payment is invalid'
	  
	  # Need to re-get the registration information as it was not re-posted, but we can reuse the payment information
	  @registration = Registration.find(params[:id])
	  
	  # Need to also re-populate split dateRecieved parameters
	  @payment.dateReceived_day = params[:payment][:dateReceived_day]
      @payment.dateReceived_month = params[:payment][:dateReceived_month]
      @payment.dateReceived_year = params[:payment][:dateReceived_year]
      
      render "new", :status => '400'
	end
  end
  
  # GET /writeOffs
  def newWriteOff
    @registration = Registration.find(params[:id])
    @payment = Payment.find(:one, :from => "/registrations/"+params[:id]+"/payments/new.json")
    
    isFinanceAdmin = current_agency_user.has_role? :Role_financeAdmin, AgencyUser
    
    if isFinanceAdmin
      # do finance admin write off
      # Redirect to paymentstatus is balance is negative or paid
      logger.info 'balance: ' + @registration.financeDetails.balance.to_s
      isLargeMessage = Payment.isLargeWriteOff( @registration.financeDetails.balance)
      if isLargeMessage == true
        logger.info 'Balance is in range for a large write off'
        # Set fixed Amount at exactly negative outstanding balance
        @payment.amount = @registration.financeDetails.balance.abs
      else
        logger.info 'Balance is out of range for a large write off'
        redirect_to :paymentstatus, :alert => isLargeMessage
      end
    else
      # Redirect to paymentstatus is balance is negative or paid
      logger.info 'balance: ' + @registration.financeDetails.balance.to_s
      isSmallMessage = Payment.isSmallWriteOff( @registration.financeDetails.balance)
      if isSmallMessage == true
        logger.info 'Balance is in range for a small write off'
        # Set fixed Amount at exactly negative outstanding balance
        @payment.amount = @registration.financeDetails.balance.abs
      else
        logger.info 'Balance is out of range for a small write off'
        redirect_to :paymentstatus, :alert => isSmallMessage
      end
    end
    
    authorize! :read, @registration
    authorize! :update, @payment
  end
  
  # POST /writeOffs
  def createWriteOff
    logger.info 'createWriteOff request has been made'
    # Get a new payment object from the parameters in the post
    @payment = Payment.new(params[:payment])
    
    # Set fields automatically for write off's
    @payment.dateReceived = Time.new.strftime("%Y-%m-%d")
    @payment.updatedByUser = current_agency_user.id.to_s
    @payment.paymentType = 'WRITEOFFSMALL'

    # Add registration Id as a prefix option
	@payment.prefix_options[:id] = params[:id]
	
	if @payment.valid?
	  logger.info 'writeOff is valid'
	  @payment.save!
	  
	  # Redirect user back to payment status
      redirect_to paymentstatus_path, alert: "Payment has been successfully entered."
	else
	  logger.info 'writeOff is invalid'
	  
	  # Need to re-get the registration information as it was not re-posted, but we can reuse the payment information
	  @registration = Registration.find(params[:id])
      
      render "newWriteOff", :status => '400'
	end
  end

end
