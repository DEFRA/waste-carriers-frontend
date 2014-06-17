require 'active_resource'

class Report
  include ActiveModel::Model

  attr_accessor :is_new, :from, :to, :route_digital, :route_assisted_digital
  attr_accessor :statuses, :business_types, :format

  validate :validate_from
  validate :validate_to

  ROUTE_OPTIONS = %w[
    DIGITAL
    ASSISTED_DIGITAL
  ]

  STATUS_OPTIONS = %w[
    active
    pending
    revoked
  ]

  FORMAT_OPTIONS = %w[
    csv
    json
    xml
  ]

  def self.route_options
    (ROUTE_OPTIONS.collect {|d| [I18n.t('route_options.'+d), d]})
  end

  def self.status_options
    (STATUS_OPTIONS.collect {|d| [I18n.t('status_options.'+d), d.upcase]})
  end

  def self.format_options
    (FORMAT_OPTIONS.collect {|d| [I18n.t('format_options.'+d), d]})
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