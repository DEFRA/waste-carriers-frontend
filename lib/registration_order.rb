class RegistrationOrder

  attr_reader :current_registration, :original_registration

  def initialize(registration)
    @current_registration = registration
    @original_registration = original_registration if is_editing_registration?
    @original_registration = ir_renewal if is_renewing_registration?
  end

  def order_types
    order_types = []
    return order_types if @current_registration.lower?
    order_types << :edit if is_editing_registration?
    order_types << :tier_change_disallowed if is_tier_change_disallowed?

    if is_editing_registration? || is_renewing_registration?
      if is_legal_entity_change?
        order_types << :change_caused_new
        order_types << :edit_charge
      else
        if is_reg_type_change?
          order_types << :change_reg_type
          order_types << :edit_charge
        end
        if is_renewing_registration?
          order_types << :renew
          order_types << :edit_charge
        end
      end
    else
      order_types << :new
    end

    return order_types.uniq
  end

  def is_reg_type_change?
    @original_registration.registrationType != @current_registration.registrationType
  end

  def is_legal_entity_change?
    business_type_changed = @original_registration.businessType != @current_registration.businessType
    limited_company_number_changed = @current_registration.limited_company? && @original_registration.company_no != @current_registration.company_no
    business_type_changed || limited_company_number_changed || is_key_people_addition?
  end

  def is_tier_change?
    @original_registration.tier != @current_registration.tier
  end

  def is_tier_change_disallowed?
    if @original_registration.try(:tier).present? && @current_registration.try(:tier).present?
      @original_registration.tier == 'LOWER' && @current_registration.tier == 'UPPER'
    end
  end

  def is_key_people_addition?
    return false unless @current_registration.partnership?
    return false if @current_registration.lower? || is_renewing_registration?

    original_key_people = original_registration.key_people.to_a.map(&:to_long_string)
    current_key_people = current_registration.key_people.to_a.map(&:to_long_string)

    return false if original_key_people == current_key_people

    original_key_people.all? { |kp| current_key_people.include?(kp) }
  end

  def within_ir_renewal_window?
    expiry_date = @current_registration.originalDateExpiry
    return false unless expiry_date.present?
    # Converts milliseconds since epoch to a DateTime if it's a string from an IR renewal
    expiry_date = DateTime.strptime(expiry_date,'%Q') if expiry_date.is_a?(String)
    expiry_date = expiry_date.to_date
    window_length = Rails.application.config.registration_renewal_window
    Date.today.between?((expiry_date - window_length), expiry_date)
  end

  def is_attempting_renewal?
    @current_registration.originalRegistrationNumber.present? &&
      @current_registration.newOrRenew.to_s.downcase != 'new'
  end

  # private

    def is_editing_registration?
      return false if @current_registration.pending?
      @current_registration.uuid.present? && @current_registration.newOrRenew == nil
    end

    def is_renewing_registration?
      is_attempting_renewal? && within_ir_renewal_window?
    end

    # def is_new_registration?
    #   @current_registration.originalRegistrationNumber.blank? && @current_registration.newOrRenew.to_s.downcase == 'new'
    # end

    def is_edit_causing_new?
      is_legal_entity_change?
    end

    def ir_renewal
      Registration.find_by_ir_number(@current_registration.originalRegistrationNumber)
    end

    def original_registration
      Registration.find_by_id(@current_registration.uuid)
    end

    def is_ir_renewal?
      @current_registration.originalRegistrationNumber.present?
    end

end
