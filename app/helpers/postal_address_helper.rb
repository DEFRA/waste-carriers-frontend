# Helper methods used by the PostalAddressController
module PostalAddressHelper
  # Used to determine if the user has set any of the fields on the postal
  # address. If all of the fields used on the postal address page are blank
  # then we assume the user has not attempted to update and we can default
  # the values to those set in the registered address.
  def set?(address)
    return true unless address.houseNumber.blank?
    return true unless address.addressLine1.blank?
    return true unless address.addressLine2.blank?
    return true unless address.addressLine3.blank?
    return true unless address.addressLine4.blank?
    return true unless address.townCity.blank?
    return true unless address.postcode.blank?
    return true unless address.country.blank?
    return true unless address.firstName.blank?
    return true unless address.lastName.blank?

    false
  end

  # If the postal address has not been set, then its fields are defaulted to
  # those held against the registered_address, plus the first and last name
  # in contact details.
  def populate_from_registered_address(registration)
    postal_adr = registration.postal_address

    reg_adr = registration.registered_address

    arg = {
      houseNumber: reg_adr.houseNumber,
      addressLine1: reg_adr.addressLine1,
      addressLine2: reg_adr.addressLine2,
      addressLine3: reg_adr.addressLine3,
      addressLine4: reg_adr.addressLine4,
      townCity: reg_adr.townCity,
      postcode: reg_adr.postcode,
      country: reg_adr.country,
      firstName: registration.firstName,
      lastName: registration.lastName }

    postal_adr.update_attributes(arg)
    postal_adr.save
  end
end
