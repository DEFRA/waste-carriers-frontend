class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ Devise.email_regexp
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.invalidEmail'))
    end
  end
end