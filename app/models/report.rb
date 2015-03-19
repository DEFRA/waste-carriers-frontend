
class Report
  include ActiveModel::Model

  attr_accessor :is_new, :search_type
  attr_accessor :from, :to, :has_declared_convictions, :conviction_check_match
  attr_accessor :routes, :tiers, :statuses, :business_types
  attr_accessor :payment_statuses, :payment_types, :charge_types
  attr_accessor :result_count
  attr_accessor :new_registration, :any_time, :renewal

  validate :validate_from
  validate :validate_to

  ROUTE_OPTIONS = %w[
    DIGITAL
    ASSISTED_DIGITAL
  ]

  TIER_OPTIONS = %w[
    UPPER
    LOWER
  ]

  STATUS_OPTIONS = %w[
    activate
    active
    inactive
    pending
    revoked
  ]

  PAYMENT_STATUS_OPTIONS = %w[
    AWAITING_PAYMENT
    FULLY_PAID
    OVERPAID
  ]

  PAYMENT_TYPE_OPTIONS = %w[
    WORLDPAY
		WORLDPAY_MISSED
		WRITEOFFSMALL
		WRITEOFFLARGE
		REFUND
		CASH
		CHEQUE
		POSTALORDER
		BANKTRANSFER
		REVERSAL
  ]

  CHARGE_TYPE_OPTIONS = %w[
    NEW
    RENEW
    COPY_CARDS
    EDIT
  ]

  # Class methods ##############################################################

  def self.route_options
    (ROUTE_OPTIONS.collect {|d| [I18n.t('route_options.'+d), d]})
  end

  def self.tier_options
    (TIER_OPTIONS.collect {|d| [I18n.t('tier_options.'+d), d.upcase]})
  end

  def self.status_options
    (STATUS_OPTIONS.collect {|d| [I18n.t('status_options.'+d), d.upcase]})
  end

  def self.payment_status_options
    (PAYMENT_STATUS_OPTIONS.collect {|d| [I18n.t('payment_status_options.'+d), d.upcase]})
  end

  def self.payment_type_options
    (PAYMENT_TYPE_OPTIONS.collect {|d| [I18n.t('payment_type_options.'+d), d.upcase]})
  end

  def self.charge_type_options
    (CHARGE_TYPE_OPTIONS.collect {|d| [I18n.t('charge_type_options.'+d), d.upcase]})
  end

  # Instance methods ###########################################################

  def registration_parameter_args

    param_args = {}

    unless from.blank?
      param_args[:from] = from
    end

    unless to.blank?
      param_args[:until] = to
    end

    unless @routes.nil? || @routes.empty?
      param_args[:route] = @routes
    end

    unless @tiers.nil? || @tiers.empty?
      param_args[:tier] = @tiers
    end

    unless @statuses.nil? || @statuses.empty?
      param_args[:status] = @statuses
    end

    unless @business_types.nil? || @business_types.empty?
      param_args[:businessType] = @business_types
    end

    unless has_declared_convictions.blank?
      param_args[:declaredConvictions] = has_declared_convictions
    end

    unless conviction_check_match.blank?
      param_args[:convictionCheckMatch] = conviction_check_match
    end

    unless result_count.blank?
      param_args[:resultCount] = result_count
    end

    param_args

  end

  def payment_parameter_args

    param_args = {}

    unless from.blank?
      param_args[:from] = from
    end

    unless to.blank?
      param_args[:until] = to
    end

    unless @payment_statuses.nil? || @payment_statuses.empty?
      param_args[:paymentStatus] = @payment_statuses
    end

    unless @payment_types.nil? || @payment_types.empty?
      param_args[:paymentType] = @payment_types
    end

    unless @charge_types.nil? || @charge_types.empty?
      param_args[:chargeType] = @charge_types
    end

    unless result_count.blank?
      param_args[:resultCount] = result_count
    end

    param_args

  end

  private

    def validate_from

      if from.blank?
        Rails.logger.debug "report 'from' field is empty"
        errors.add(:from, I18n.t('errors.messages.blank') )
        return
      end

      Time.parse(from)

      unless from.is_date?
        Rails.logger.debug "report 'from' field is invalid"
        errors.add(:from, I18n.t('errors.messages.invalid_date') )
      end

    end

    def validate_to

      if to.blank?
        Rails.logger.debug "report 'to' field is empty"
        errors.add(:to, I18n.t('errors.messages.blank') )
        return
      end

      Time.parse(to)

      unless to.is_date?
        Rails.logger.debug "report 'to' field is invalid"
        errors.add(:to, I18n.t('errors.messages.invalid_date') )
      end

    end

end
