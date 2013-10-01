class Registration < ActiveRecord::Base
  attr_accessible :address, :companyRegistrationNumber, :emailAddress, :firstName, :houseNumber, :individualsType, :lastName, :organisationName, :organisationType, :phoneNumber, :postcode, :publicBodyType, :registerAs, :title, :uprn
end
