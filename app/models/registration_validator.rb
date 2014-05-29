class RegistrationValidator < ActiveModel::Validator
  def validate(record)
    case record.current_step
      when 'businesstype'
        record.errors[:businessType] << 'must be completed' if record.businessType.blank?
        record.errors[:businessType] << 'invalid' unless record.businessType.in? Registration::BUSINESS_TYPES
      when 'otherbusinesses'
        record.errors[:otherBusinesses] << 'must be completed' if record.otherBusinesses.blank?
        record.errors[:otherBusinesses] << 'invalid' unless record.businessType.in? Registration::YES_NO_ANSWER
    end
  end
end