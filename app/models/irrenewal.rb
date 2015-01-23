#This class represents an IRRenewal in Mongo

class Irrenewal

  include Mongoid::Document

  field :applicant_type,         :type => String
  field :expiry_date,            :type => Date
  field :reference_number,       :type => String
  field :registration_type,      :type => String
  field :ir_type,                :type => String
  field :company_name,           :type => String
  field :trading_name,           :type => String
  field :company_number,         :type => String
  field :true_registration_type, :type => String
  field :permit_holder_name,     :type => String
  field :dob,                    :type => Date
  field :party_sub_type,         :type => String
  field :partnership_name,       :type => String
  field :party_name,             :type => String

end