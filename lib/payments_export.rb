class PaymentsExport
  # Generates CSV output of payment information

  attr_reader :report, :registrations

  def initialize(report, registrations)
    @report = report
    @registrations = registrations
  end

  def generate_csv
    CSV.generate do |csv|
      csv << headings
      rows.each do |row|
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
          rpw[:payment_updated_by],
          row[:payment_received],
          row[:balance]
        ]
      end
    end
  end

  def rows
    registrations.map do |registration|
      finance_details = registration.finance_details
      next unless finance_details.present?
      orders = finance_details.first.orders
      next unless orders.present?

      orders.map do |order|
        related_payments = payments_for_order(registration, order)
         order.order_items.map do |order_item|
           row(registration, order, order_item, related_payments)
         end
      end
    end
  end

  def row(registration, order, order_item, related_payments)
    row = {
      reg_identifier: registration.regIdentifier,
      company_name: registration.companyName,
      status: registration.metaData.first.status,
      route: registration.metaData.first.route,
      transaction_date: format_time(order.dateCreated),
      order_code: order.orderCode,
      charge_type: order_item.type,
      charge_amount: formatted_money(order_item.amount),
      charge_updated_by: order.updatedByUser,
      payment_type: order.paymentMethod,
      reference: order_item.reference,
      balance: formatted_money(registration.finance_details.first.balance)
    }

    if related_payments.present?
      additional_fields = {
        payment_amount: formatted_money(payment.amount),
        comment: payment.comment,
        payment_updated_by: payment.updatedByUser,
        payment_received: formatted_time(payment.dateReceived)
      }
      row.reverse_merge!(additional_fields)
    end

    row
  end

  private

  delegate :t, to: I18n

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
    #humanized_money(Money.new(pence), { :no_cents_if_whole => false, :symbol => false })
    Money.new(pence)
  end

  def formatted_time(time)
    time.to_s
  end

end
