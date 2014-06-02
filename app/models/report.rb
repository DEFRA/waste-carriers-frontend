require 'active_resource'

class Report
  include ActiveModel::Model

  attr_accessor :is_new, :from, :to, :route_digital, :route_assisted_digital, :statuses, :business_types

  validate :validate_from
  validate :validate_to

  STATUS_OPTIONS = %w[
    active
    pending
    revoked
  ]

  def self.status_options
    (STATUS_OPTIONS.collect {|d| [I18n.t('status_options.'+d), d]})
  end

  private

    def validate_from

      if from.blank?
        Rails.logger.debug "report 'from' field is empty"
        errors.add(:from, I18n.t('errors.messages.blank') )
      elsif from =~ /^\d\d\/\d\d\/\d\d\d\d$/
        Rails.logger.debug "report 'from' field is invalid"
        errors.add(:from, I18n.t('errors.messages.invalid') )
      end

    end

    def validate_to

      if to.blank?
        Rails.logger.debug "report 'to' field is empty"
        errors.add(:to, I18n.t('errors.messages.blank') )
      elsif to =~ /^\d\d\/\d\d\/\d\d\d\d$/
        Rails.logger.debug "report 'to' field is invalid"
        errors.add(:to, I18n.t('errors.messages.invalid') )
      end

    end

end