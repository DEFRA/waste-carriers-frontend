#Controller for handling the responses received from Worldpay (via the user's browser)

class WorldpayController < ApplicationController

  include WorldpayHelper

  def success
    #TODO - redirect to some other page after processing/saving the payment
    #redirect_to paid_path
    @registration = Registration.find session[:registration_id]

    if process_payment
      next_step = if @registration.assisted_digital? || user_signed_in?
                    print_path(@registration)
                    #Note from Georg: I think we will eventually want to show the 'finish' path
                    #finish_path(@registration)
                  elsif @registration.user.confirmed?
                    confirmed_path
                  else
                    pending_path
                  end
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

  private

    def process_payment

      payment_processed = true

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
        @payment.updatedByUser = 'you@example.com'
        @payment.amount = paymentAmount.to_i
        @payment.orderKey = orderCode
        @payment.currency = paymentCurrency
        @payment.paymentType = 'WORLDPAY'
        @payment.worldPayPaymentStatus = paymentStatus
        @payment.mac_code = mac
        @payment.registrationReference = 'Worldpay'
        @payment.comment = 'Paid via Worldpay'
        @payment.prefix_options[:id] = session[:registration_id]

        #TODO re-enable validation and saving - current validation rules are geared towards offline payments
        if @payment.valid?
          @payment.save!
          #@payment.save(:validate => false)
        else
          logger.error 'Payment is not valid! ' + @payment.errors.messages.to_s
          payment_processed = false
          @payment.save(:validate => false)
        end
      end

      payment_processed
    end

end
