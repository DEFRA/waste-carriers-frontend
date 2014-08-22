
class Report
  include ActiveModel::Model

  attr_accessor :is_new, :from, :to, :has_declared_convictions, :is_criminally_suspect

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

  # Custom getters and setters #################################################

  def routes
    unless @routes
      @routes = []
    end
    @routes
  end

  def routes=(new_routes)
    @routes = filter_for_blanks new_routes
  end

  def tiers
    unless @tiers
      @tiers = []
    end
    @tiers
  end

  def tiers=(new_tiers)
    @tiers = filter_for_blanks new_tiers
  end

  def statuses
    unless @statuses
      @statuses = []
    end
    @statuses
  end

  def statuses=(new_statuses)
    @statuses = filter_for_blanks new_statuses
  end

  def business_types
    unless @business_types
      @business_types = []
    end
    @business_types
  end

  def business_types=(new_business_types)
    @business_types = filter_for_blanks new_business_types
  end

  # Instance methods ###########################################################

  def filter_for_blanks(values)

    filtered = []

    Rails.logger.debug 'REPORT::filter_for_blanks'
    unless values.nil?
      Rails.logger.debug 'REPORT::filter_for_blanks - not nil'
      filtered = values.reject(&:blank?)
    end

    unless filtered
      Rails.logger.debug 'REPORT::filter_for_blanks - filtered is nil'
      filtered = []
    end

    filtered

  end

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
