
class Report
  include ActiveModel::Model

  attr_accessor :is_new, :from, :to, :routes, :route_digital, :route_assisted_digital
  attr_accessor :tiers, :statuses, :business_types, :has_declared_convictions
  attr_accessor :is_criminally_suspect

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

  # Instance methods ###########################################################

  def parameter_args

    param_args = {}

    unless from.blank?
      param_args[:from] = from
    end

    unless to.blank?
      param_args[:until] = to
    end

    # param_args[:route] = [
    #   route_digital,
    #   route_assisted_digital
    #   ].reject(&:blank?)

    filtered_routes = routes.reject(&:blank?)
    unless filtered_routes.empty?
      param_args[:route] = filtered_routes
    end

    filtered_statues = statuses.reject(&:blank?)
    unless filtered_statues.empty?
      param_args[:status] = filtered_statues
    end

    filtered_business_types = business_types.reject(&:blank?)
    unless filtered_business_types
      param_args[:businessType] = filtered_business_types
    end

    filtered_tiers = tiers.reject(&:blank?)
    unless filtered_tiers
      param_args[:tier] = filtered_tiers
    end

    unless has_declared_convictions.blank?
      param_args[:declaredConvictions] = has_declared_convictions
    end

    unless is_criminally_suspect.blank?
      param_args[:criminallySuspect] = is_criminally_suspect
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
