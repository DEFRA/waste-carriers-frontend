class PaymentController < ApplicationController

  def enterPayment
    @registration = Registration.find_by_id(params[:id])
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

  end

  def savePayment
    logger.info 'savePayment request has been made'
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
	  @registration = Registration.find_by_id(params[:id])

	  # Need to also re-populate split dateRecieved parameters
	  @payment.dateReceived_day = params[:payment][:dateReceived_day]
      @payment.dateReceived_month = params[:payment][:dateReceived_month]
      @payment.dateReceived_year = params[:payment][:dateReceived_year]

      render "enterPayment", :status => '400'
	end

  end

end
