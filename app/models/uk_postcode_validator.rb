class UkPostcodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank?
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.blank_post_code'))
    else
      unless value =~ /\A\s*((GIR\s*0AA)|((([A-PR-UWYZ][0-9]{1,2})|(([A-PR-UWYZ][A-HK-Y][0-9]{1,2})|(([A-PR-UWYZ][0-9][A-HJKSTUW])|([A-PR-UWYZ][A-HK-Y][0-9][ABEHMNPRVWXY]))))\s*[0-9][ABD-HJLNP-UW-Z]{2}))\s*\z/i
        record.errors[attribute] << (options[:message] || I18n.t('errors.messages.invalid_post_code'))
      end
    end
  end
end
