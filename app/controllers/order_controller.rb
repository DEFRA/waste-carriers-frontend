class OrderController < ApplicationController

  include OrderHelper
  include WorldpayHelper
  include RegistrationsHelper

  #We require authentication (and authorisation) largely only for editing registrations,
  #and for viewing the finished/completed registration.

  # Removed as external user not logged in at time of first payment
  #before_filter :authenticate_external_user!, :only => [:index, :new, :create]

  # GET /index
  def index
    # does nothing
  end

  # GET /new
  def new
    # Renders a new Order page (formally newPayment)
    @order = Order.new if @order == nil

    logger.debug 'renderType session: ' + session[:renderType].to_s
    @renderType = session[:renderType]
    # Could also determine here what view to render
    if !@order.isValidRenderType? @renderType
      logger.error 'Cannot find a renderType variable in the session. It is needed to determine the type of payment page to render.'
      logger.error 'Rendering Page not found'
      renderNotFound
    end

    # Setup page
    setup_registration 'payment', true
    if !@registration.copy_cards
      @registration.copy_cards = 0
    end

    # Calculate fees shown on page
    @registration = calculate_fees @registration, @renderType

  end

  # POST /create
  def create

    #
    # TODO:
    # Calculates what type of create is required based on the route required
    #
    logger.debug 'params - reg: ' + params[:registration].to_s
    logger.debug 'params - order: ' + params[:order].to_s

    # for now assume old code is correct
    setup_registration 'payment'
    # Must get render type to determine what actions to take, and for rerendering any errors if found
    @renderType = session[:renderType]
    logger.debug 'renderType session: ' + session[:renderType].to_s

    # Determine what kind of payment selected and redirect to other action if required
    if params[:offline_next] == I18n.t('registrations.form.pay_offline_button_label')
      @order = prepareOfflinePayment @registration, @renderType
    else
      @order = prepareOnlinePayment @registration, @renderType
    end

    logger.info "Check if the registration is valid. This checks the data entered is valid"
    if @registration.valid?

      if @order.valid?
        logger.info "Determining order save/update"
        if @renderType.eql? Order.new_registration_identifier
          logger.info "Saving the order"
          # New registration, so update existing order
          if @order.save! @registration.uuid
            # order saved successfully

            #
            # TODO:
            # cleanup render Type from session
            #
            # However: should be done later than here, because otherwise you cannot select one payment type,
            #           go back in browser and select again link you can currently
            #session.delete(:renderType)

            # Re-get registration from the database to update the local redis version
            @registration = Registration.find_by_id(@registration.uuid)
            logger.info "Updated redis version after order save!"

          else
            @order.errors.add(:exception, @order.exception.to_s)

            # error updating services
            logger.warn 'The update order was not saved to services.'
            render 'new', :status => '400'
            return
          end
        else
          # Must be an edit, update or copy card order
          logger.info "Committing the order"
          if @order.commit @registration.uuid
            # Order commited to services
            logger.info "New order committed to services"

            # Re-get registration from the database to update the local redis version
            @registration = Registration.find_by_id(@registration.uuid)
            logger.info "Updated redis version after order commit"

          else
            @order.errors.add(:exception, @order.exception.to_s)

            # error updating services
            logger.warn 'The new order was not commited to services.'
            render 'new', :status => '400'
            return
          end
        end
      else
  	    #We should hardly get into here given we constructed the order just above...
  	    logger.warn 'The new Order is invalid: ' + @order.errors.full_messages.to_s
  	    render 'new', :status => '400'
        return
      end

      logger.info "About to redirect to Worldpay/Offline payment"
      if params[:offline_next] == I18n.t('registrations.form.pay_offline_button_label')
        logger.info "The registration is valid - redirecting to Offline payment page..."
        redirect_to newOfflinePayment_path(:orderCode => @order.orderCode )
      else
        logger.info "The registration is valid - redirecting to Worldpay..."
        redirect_to_worldpay(@registration, @order)
      end
      return
    else
      logger.error "validation errors: #{@registration.errors.messages.to_s}"
      logger.error "The registration is not valid! " + @registration.to_s
      render 'new', :status => '400'
    end

  end


  #######################################################################################################

  private

# Removed as not required
#  # Duplicated from registraions controller
#  def authenticate_external_user!
#    if !is_admin_request? && !agency_user_signed_in?
#      authenticate_user!
#    end
#  end

end
