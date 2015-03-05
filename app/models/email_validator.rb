class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank?
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.blank_email'))
    else
      unless value =~ Devise.email_regexp
        record.errors[attribute] << (options[:message] || I18n.t('errors.messages.invalid_email'))
      end
    end
  end
end