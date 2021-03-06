class Report
  include ActiveModel::Model

  attr_accessor :is_new, :search_type
  attr_accessor :from, :to, :has_declared_convictions, :conviction_check_match
  attr_accessor :routes, :tiers, :statuses, :business_types, :copy_cards
  attr_accessor :payment_status, :payment_types, :charge_types
  attr_accessor :result_count

  validate :validate_from
  validate :validate_to
  validate :validate_payment_status, if: -> {search_type == :payment}

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

  COPY_CARD_OPTIONS = %w[
    NEW
    ANY
    RENEW
    NONE
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

  def self.copy_card_options
    (COPY_CARD_OPTIONS.collect {|d| [I18n.t('copy_card_options.'+d), d.upcase]})
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

    unless @routes.nil? || @routes.empty? || @routes == '[]'
      param_args[:route] = @routes
    end

    unless @tiers.nil? || @tiers.empty? || @tiers == '[]'
      param_args[:tier] = @tiers
    end

    unless @statuses.nil? || @statuses.empty? || @statuses == '[]'
      param_args[:status] = @statuses
    end

    unless @business_types.nil? || @business_types.empty? || @business_types == '[]'
      param_args[:businessType] = @business_types
    end

    unless @copy_cards.nil? || @copy_cards.empty? || @copy_cards == '[]'
      param_args[:copyCards] = @copy_cards
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

    unless payment_status.blank?
      param_args[:paymentStatus] = payment_status
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

  def copy_cards_parameter_args

    param_args = {}

    unless from.blank?
      param_args[:from] = from
    end

    unless to.blank?
      param_args[:until] = to
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

  private

    def validate_from
      if from.blank?
        Rails.logger.debug "report 'from' field is empty"
        errors.add(:from, I18n.t('errors.messages.blank') )
        return
      end

      begin
        Time.parse(from)
        unless from.to_s =~ /^(0[1-9]|[12][0-9]|3[01])[- \/](0[1-9]|1[012])[- \/](19|20)\d\d$/
          Rails.logger.debug "report 'from' field is invalid"
          errors.add(:from, I18n.t('errors.messages.invalid_date_short') )
        end
      rescue ArgumentError
        Rails.logger.debug "report 'from' field is invalid"
        errors.add(:from, I18n.t('errors.messages.invalid_date_short') )
      end
    end

    def validate_to
      if to.blank?
        Rails.logger.debug "report 'to' field is empty"
        errors.add(:to, I18n.t('errors.messages.blank') )
        return
      end

      begin
       Time.parse(to)
       unless to.to_s =~ /^(0[1-9]|[12][0-9]|3[01])[- \/](0[1-9]|1[012])[- \/](19|20)\d\d$/
         Rails.logger.debug "report 'to' field is invalid"
         errors.add(:to, I18n.t('errors.messages.invalid_date_short') )
       end
      rescue ArgumentError
        Rails.logger.debug "report 'to' field is invalid"
        errors.add(:to, I18n.t('errors.messages.invalid_date_short') )
      end
    end

    def validate_payment_status
      if payment_status.blank?
        errors.add(:payment_status, I18n.t('errors.messages.missing_payment_status') )
      end
    end
end
