class Irrenewals

  include Mongoid::Document

  field :applicantType,         :type => String,  :default => ''
  field :expiryDate,            :type => Date,    :default => '0000-01-01T00:00:00.000Z'
  field :referenceNumber,       :type => String,  :default => ''
  field :registrationType,      :type => String,  :default => ''
  field :irType,                :type => String,  :default => ''
  field :companyName,           :type => String,  :default => ''
  field :tradingName,           :type => String,  :default => ''
  field :companyNumber,         :type => String,  :default => ''
  field :trueRegistrationType,  :type => String,  :default => ''
  field :permitHolderName,      :type => String,  :default => ''
  field :dateOfBirth,           :type => Date
  field :partySubType,          :type => String
  field :partnershipName,       :type => String
  field :partyName,             :type => String

end