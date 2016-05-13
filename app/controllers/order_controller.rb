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
    # Renders a new Order page (formerly newPayment)
    @order ||= Order.new

    @renderType = session[:renderType]
    unless @order.isValidRenderType? @renderType
      logger.error 'Cannot find a renderType variable in the session. It is needed to determine the type of payment page to render.'
      logger.debug 'Rendering Page not found'
      renderNotFound
    end

    # Setup page
    setup_registration 'payment', true
    unless @registration
      logger.warn 'No @registration. Cannot show order page.'
      renderNotFound
      return
    end

    @registration.copy_cards = 0 unless @registration.copy_cards

    if @renderType.eql? Order.extra_copycards_identifier
      @registration.update(copy_card_only_order: 'yes')
    end

    # Calculate fees shown on page
    @registration = calculate_fees(@registration, @renderType)
  end

  # POST /create
  def create
    setup_registration 'payment'

    # Must get render type to determine what actions to take, and for
    # rerendering any errors if found.
    @renderType = session[:renderType]
    logger.debug 'renderType session: ' + session[:renderType].to_s

    # Determine what kind of payment selected and redirect to other action if required
    bank_transfer = (@registration.payment_type === "bank_transfer")

    if bank_transfer
      @order = prepareOfflinePayment(@registration, @renderType)
    else
      @order = prepareOnlinePayment(@registration, @renderType)
    end

    logger.debug "Check if the registration is valid. This checks the data entered is valid"
    if @registration.valid?

      if @order.valid?
        logger.debug "Determining order save/update"
        if @renderType.eql?(Order.new_registration_identifier) || isIRRenewal?(@registration, @renderType) || @renderType.eql?(Order.editrenew_caused_new_identifier)
          logger.debug "Saving the order"
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
            regFromDB = Registration.find_by_id(@registration.uuid)
            logger.debug "Updated redis version after order save!"

            # Get all nested children out of registration, specifically finaince details and override local copy in redis and save to redis
            @registration.finance_details.replace([regFromDB.finance_details.first])
            @registration.save

          else
            @order.errors.add(:exception, @order.exception.to_s)

            # error updating services
            logger.warn 'The update order was not saved to services.'
            render 'new', :status => '400'
            return
          end
        else

          # Remove un-needed fee values from the registration about to be saved
          @registration.total_fee = nil
          @registration.registration_fee = nil
          @registration.copy_card_fee = nil
          @registration.copy_cards = nil

          #
          # Save the updated registration prior to making the new order, that way the returned order contains the up to date registration
          # including any changes that have happended to the registration.
          #
          # The downside to this is an edge-case whereby the registration saves, and the commit fails so we need to ensure
          # that registrations marked as renewalRequested are treated appropriately
          #
          if @registration.save!
            logger.debug "Registration saved!"
            @registration.save
          else
            logger.debug "Failed to save registration prior to order"
            @order.errors.add(:exception, @registration.exception.to_s)

            # error updating services
            render 'new', :status => '400'
            return
          end

          # Must be an edit, update or copy card order
          logger.debug "Committing the order"
          if @order.commit @registration.uuid
            # Order commited to services
            logger.debug "New order committed to services"

            # Re-get registration from the database to update the local redis version
            @registration = Registration.find_by_id(@registration.uuid)
            logger.debug "Updated redis version after order commit"
            @registration.save

          else
            @order.errors.add(:exception, @order.exception.to_s)

            # error updating services
            logger.warn 'The new order was not committed to services.'
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

      logger.debug "About to redirect to Worldpay/Offline payment"
      set_google_analytics_payment_indicator(session, @order)
      if bank_transfer
        logger.debug "The registration is valid - redirecting to Offline payment page..."
        redirect_to newOfflinePayment_path(:orderCode => @order.orderCode )
      else
        logger.debug "The registration is valid - redirecting to Worldpay..."

        response = send_xml(create_xml(@registration, @order))
        unless response
          render 'new', :status => '400'
          return
        end

        redirect_to get_redirect_url(parse_xml(response.body))
      end
      return
    else
      logger.debug "validation errors: #{@registration.errors.messages.to_s}"
      render 'new', :status => '400'
    end

  end

end
