
class Report
  include ActiveModel::Model

  attr_accessor :is_new, :from, :to, :has_declared_convictions, :is_criminally_suspect
  attr_accessor :routes, :tiers, :statuses, :business_types
  attr_accessor :payment_statuses, :payment_types, :charge_types

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
    pending
    fully_paid
    overpaid
    underpaid
  ]

  PAYMENT_TYPE_OPTIONS = %w[
    credit_debit_card
    bank_transfer
    cheque
    cash
    postal_order
  ]

  CHARGE_TYPE_OPTIONS = %w[
    new_application
    renewal
    copy_cards
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

  def parameter_args

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

    unless is_criminally_suspect.blank?
      param_args[:criminallySuspect] = is_criminally_suspect
    end

    unless @payment_statuses.nil? || @payment_statuses.empty?
      param_args[:payment_statuses] = @payment_statuses
    end

    unless @payment_types.nil? || @payment_types.empty?
      param_args[:payment_types] = @payment_types
    end

    unless @charge_types.nil? || @charge_types.empty?
      param_args[:charge_types] = @charge_types
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

      unless to.is_date?
        Rails.logger.debug "report 'to' field is invalid"
        errors.add(:to, I18n.t('errors.messages.invalid_date') )
      end

    end

end
