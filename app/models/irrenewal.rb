#This class represents an IRRenewal in Mongo

class Irrenewal

  include Mongoid::Document

  field :applicantType,          :type => String
  field :expiryDate,             :type => Date
  field :referenceNumber,        :type => String
  field :registrationType,       :type => String
  field :irType,                 :type => String
  field :companyName,            :type => String
  field :tradingName,            :type => String
  field :companyNumber,          :type => String
  field :trueRegistrationType,   :type => String
  field :permitHolderName,       :type => String
  field :dateOfBirth,            :type => Date
  field :partySubType,           :type => String
  field :partnershipName,        :type => String
  field :partyName,              :type => String

  def expired?
    expiryDate.to_date <= Date.today
  end

  def in_renewal_window?
    return false if expired?
    # If the registration expires in more than x months from now, its outside
    # the renewal window
    expiryDate.to_date < Rails.configuration.registration_renewal_window.from_now
  end

  def already_renewed?
    registration = Registration.find_by_original_registration_no(referenceNumber)

    return true if registration.present? && registration.metaData.first.status != 'PENDING'

    false
  end

end
