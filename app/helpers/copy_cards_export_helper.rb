# Provides methods used when exporting Registration data to CSV, or a table
# embedded in a web page.  Each method provides a data array; formatting should
# be handled by the caller.
module CopyCardsExportHelper
  include ApplicationHelper

  def copy_cards_export_get_headers(style)
    case style
    when 'full'
      get_copy_cards_headers_full
    else
      fail 'Unrecognised style requested'
    end
  end

  def copy_cards_export_get_registration_data(style, registration)
    case style
    when 'full'
      get_copy_cards_registration_data_full(registration)
    else
      fail 'Unrecognised style requested'
    end
  end

  def copy_cards_export_get_person_data(style, registration, person)
    case style
    when 'full'
      get_copy_cards_keyperson_data_full(registration, person)
    else
      fail 'Unrecognised style requested'
    end
  end

  def pad_array_to_match_length(template, target)
    length_diff = template.length - target.length
    if length_diff > 0
      target.concat(Array.new(length_diff, ''))
    else
      target
    end
  end

  private

  def bool_to_string(value)
    value ? 'Yes' : 'No'
  end

  def get_copy_cards_headers_full()
    [
      I18n.t('reports.fields.reg_identifier'),
      I18n.t('reports.fields.number_of_copy_cards'),
      I18n.t('reports.fields.order_code'),
      I18n.t('reports.fields.price_paid'),
      I18n.t('reports.fields.total_price_paid'),
      I18n.t('reports.fields.company_name'),
      I18n.t('reports.fields.company_no'),
      I18n.t('reports.fields.registered_address'),
      I18n.t('reports.fields.houseNumber'),
      I18n.t('reports.fields.addressLine1'),
      I18n.t('reports.fields.addressLine2'),
      I18n.t('reports.fields.addressLine3'),
      I18n.t('reports.fields.addressLine4'),
      I18n.t('reports.fields.townCity'),
      I18n.t('reports.fields.postcode'),
      I18n.t('reports.fields.country'),
      I18n.t('reports.fields.postal_address'),
      I18n.t('reports.fields.houseNumber'),
      I18n.t('reports.fields.addressLine1'),
      I18n.t('reports.fields.addressLine2'),
      I18n.t('reports.fields.addressLine3'),
      I18n.t('reports.fields.addressLine4'),
      I18n.t('reports.fields.townCity'),
      I18n.t('reports.fields.postcode'),
      I18n.t('reports.fields.country'),
      I18n.t('reports.fields.contact_email'),
      I18n.t('reports.fields.first_name'),
      I18n.t('reports.fields.last_name'),
      I18n.t('reports.fields.phone_number'),
      I18n.t('reports.fields.business_type'),
      I18n.t('reports.fields.tier'),
      I18n.t('reports.fields.registration_type'),
      I18n.t('reports.fields.date_registered'),
      I18n.t('reports.fields.date_activated'),
      I18n.t('reports.fields.expires_on'),
      I18n.t('reports.fields.date_order_created'),
      I18n.t('reports.fields.date_order_last_updated'),
      I18n.t('reports.fields.payment_method'),
      I18n.t('reports.fields.status'),
      I18n.t('reports.fields.pending_payment'),
      I18n.t('reports.fields.amount_outstanding'),
      I18n.t('reports.fields.pending_convictions'),
      I18n.t('reports.fields.declared_convictions'),
    ]
  end

  def get_copy_cards_registration_data_full(registration)
    is_upper = registration.upper?
    registered_addr = registration.registered_address
    postal_addr = registration.postal_address
    copy_cards_orders = registration.copy_card_orders
    copy_cards_orders.each { |order| Rails.logger.debug "========#####>>>>> #{order.orderId}" }
    data_rows = Array.new
    copy_cards_orders.each {
        |order| copy_cards_order_item = order.copy_cards_order_item
        data_rows.append [
          registration.regIdentifier,
          copy_cards_order_item.description,
          order.orderCode,
          "%.2f" % (copy_cards_order_item.amount.to_f / 100) + ' ' + copy_cards_order_item.currency,
          "%.2f" % (order.totalAmount.to_f / 100) + ' ' + order.currency,
          registration.companyName,
          is_upper ? registration.company_no : '',
          '',
          registered_addr.houseNumber,
          registered_addr.addressLine1,
          registered_addr.addressLine2,
          registered_addr.addressLine3,
          registered_addr.addressLine4,
          registered_addr.townCity,
          registered_addr.postcode,
          registered_addr.country,
          '',
          postal_addr.nil? ? '' : postal_addr.houseNumber,
          postal_addr.nil? ? '' : postal_addr.addressLine1,
          postal_addr.nil? ? '' : postal_addr.addressLine2,
          postal_addr.nil? ? '' : postal_addr.addressLine3,
          postal_addr.nil? ? '' : postal_addr.addressLine4,
          postal_addr.nil? ? '' : postal_addr.townCity,
          postal_addr.nil? ? '' : postal_addr.postcode,
          postal_addr.nil? ? '' : postal_addr.country,
          registration.contactEmail,
          registration.firstName,
          registration.lastName,
          registration.phoneNumber,
          registration.businessType,
          registration.tier,
          is_upper ? registration.registrationType : '',
          format_as_date_only(registration.metaData.first.dateRegistered),
          format_as_date_only(registration.metaData.first.dateActivated, blank_if_epoch: true),
          format_as_date_only(registration.expires_on, blank_if_epoch: true),
          format_as_date_only(order.dateCreated, blank_if_epoch: true),
          format_as_date_only(order.dateLastUpdated, blank_if_epoch: true),
          order.paymentMethod,
          registration.metaData.first.status,
          is_upper ? bool_to_string(!registration.paid_in_full?) : '',
          "%.2f" % (registration.finance_details.first.balance.to_f / 100) + ' ' + order.currency,
          is_upper ? bool_to_string(registration.is_awaiting_conviction_confirmation?) : '',
          is_upper ? registration.declaredConvictions : '',
        ]
    }
    data_rows
    end

end
