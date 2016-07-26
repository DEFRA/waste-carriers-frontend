class UkCompanyNumberValidator < ActiveModel::EachValidator

  VALID_COMPANIES_HOUSE_REGISTRATION_NUMBER_REGEX = /\A((\d{1,8})|([A-Z]{2}\d{6})|([A-Z]{2}\d{5}[A-Z]{1})|([A-Z]{2}\d{4}[A-Z]{2}))\z/i

  def validate_each(record, attribute, value)
    if value.blank?
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.blank_uk_company_number'))
    elsif !value.match(VALID_COMPANIES_HOUSE_REGISTRATION_NUMBER_REGEX)
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.invalid_uk_company_number_characters'))
    else
      case CompaniesHouseCaller.new(value).status
        when :not_found
          record.errors[attribute] << (options[:message] || I18n.t('errors.messages.not_found_uk_company_number'))
        when :inactive
          record.errors[attribute] << (options[:message] || I18n.t('errors.messages.inactive_uk_company_number'))
        when :error_calling_service
          record.errors[attribute] << (options[:message] || I18n.t('errors.messages.companies_house_service_error'))
      end
    end
  end
end
