require 'active_resource'

class Report
  include ActiveModel::Model

  attr_accessor :is_new, :from, :to, :route_digital, :route_assisted_digital

  validate :validate_from
  validate :validate_to

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