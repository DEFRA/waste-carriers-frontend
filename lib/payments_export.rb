class PaymentsExport
  # Generates CSV output of payment information

  attr_reader :report, :registrations

  delegate :t, to: I18n

  def initialize(report, registrations)
    @report = report
    @registrations = registrations
  end

  def generate_csv
    CSV.generate do |csv|
      csv << headings
      rows.flatten.each do |row|
        csv << [
          row[:reg_identifier],
          row[:company_name],
          row[:status],
          row[:route],
          row[:transaction_date],
          row[:order_code],
          row[:charge_type],
          row[:charge_amount],
          row[:charge_updated_by],
          row[:payment_type],
          row[:reference],
          row[:payment_amount],
          row[:comment],
          row[:payment_updated_by],
          row[:payment_received],
          row[:balance]
        ]
      end
    end
  end

  private

  def rows
    registrations.flat_map do |registration|
      begin
        [
          order_rows(registration),
          unrelated_payment_rows(registration)
        ].compact
      rescue => e
        notify_airbake(e)
        [error_row(registration)]
      end
    end
  end

  def order_rows(registration)
    finance_details = registration.finance_details
    return nil unless finance_details.present?
    orders = finance_details.first.orders
    return nil unless orders.present?

    orders.flat_map do |order|
      related_payments = payments_for_order(registration, order)
      order_rows = order.order_items.flat_map do |order_item|
        row(registration, order, order_item)
      end
      payment_rows = related_payments.flat_map do |payment|
        payment_row(registration, payment)
      end
      [order_rows, payment_rows].compact
    end
  end

  def unrelated_payment_rows(registration)
    finance_details = registration.finance_details
    return nil unless finance_details.present?
    codes = registration_order_codes(registration)

    unrelated_payments = finance_details.first.payments.to_a.select do |p|
      codes.exclude?(p.orderKey)
    end

    unrelated_payments.flat_map do |payment|
      payment_row(registration, payment)
    end
  end

  def row(registration, order, order_item)
    {
      reg_identifier: registration.regIdentifier,
      company_name: registration.companyName,
      status: registration.metaData.first.status,
      route: registration.metaData.first.route,
      transaction_date: formatted_time(order.dateCreated),
      order_code: order.orderCode,
      charge_type: order_item.type,
      charge_amount: formatted_money(order_item.amount),
      charge_updated_by: order.updatedByUser,
      payment_type: order.paymentMethod,
      reference: order_item.reference,
      balance: formatted_money(registration.finance_details.first.balance)
    }
  end

  def payment_row(registration, payment)
    {
      reg_identifier: registration.regIdentifier,
      company_name: registration.companyName,
      status: registration.metaData.first.status,
      route: registration.metaData.first.route,
      transaction_date: formatted_time(payment.dateEntered),
      reference: payment.registrationReference,
      payment_type: payment.paymentType,
      payment_amount: formatted_money(payment.amount),
      comment: payment.comment,
      payment_updated_by: payment.updatedByUser,
      payment_received: formatted_time(payment.dateReceived),
      balance: formatted_money(registration.finance_details.first.balance)
    }
  end

  def error_row(registration)
    {
      reg_identifier: registration.try(:regIdentifier),
      company_name: t('reports.errors.csv_row_error')
    }
  end

  def headings
    [
      t('reports.fields.reg_identifier'),
      t('reports.fields.company_name'),
      t('reports.fields.status'),
      t('reports.fields.route'),
      t('reports.fields.transaction_date'),
      t('reports.fields.order_code'),
      t('reports.fields.charge_type'),
      t('reports.fields.charge_amount'),
      t('reports.fields.charge_updated_by'),
      t('reports.fields.payment_type'),
      t('reports.fields.reference'),
      t('reports.fields.payment_amount'),
      t('reports.fields.comment'),
      t('reports.fields.payment_updated_by'),
      t('reports.fields.payment_received'),
      t('reports.fields.balance')
    ]
  end

  def payments_for_order(registration, order)
    payments = registration.finance_details.first.payments
    return [] unless payments.present?
    payments.to_a.select { |payment| payment.orderKey == order.orderCode }
  end

  def formatted_money(pence)
    Money.new(pence || 0)
  end

  def formatted_time(time)
    # %Q - Unix time
    # %F - The ISO 8601 date format (%Y-%m-%d)
    # %T - 24-hour time (%H:%M:%S)
    Time.strptime(time.to_s, '%Q').strftime('%F %T')
  end

  def registration_order_codes(registration)
    registration.finance_details.first.orders.map(&:orderCode)
  end

  def notify_airbake(e)
    Airbrake.notify(e)
  end

end
