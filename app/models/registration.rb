require 'active_resource'

class Registration < ActiveResource::Base
# In Rails 4, attr_accessible has been replaced by strong parameters in controllers
#  attr_accessible :address, :email, :firstName, :houseNumber, :individualsType, :lastName, :companyName, :businessType, :phoneNumber, :postcode, :publicBodyType, :registerAs, :title, :uprn, :publicBodyTypeOther, :streetLine1, :streetLine2, :townCity, :declaration

  self.site = 'http://localhost:9090'
  self.format = :json

  attr_writer :current_step

  #The schema is not strictly necessary for a model based on ActiveRessource, but helpful for documentation
  schema do
    string :businessType
    string :companyName
    string :individualsType
    string :publicBodyType
    string :publicBodyTypeOther
    string :houseNumber
    string :streetLine1
    string :streetLine2
    string :townCity
    string :postcode
    string :title
    string :firstName
    string :lastName
    string :phoneNumber
    string :email
    string :declaration
    # TODO: Determine if this is needed?
    string :uprn
    string :address
  end

  validates_presence_of :businessType, :if => lambda { |o| o.current_step == "business" }
  validates_presence_of :companyName, :if => lambda { |o| o.current_step == "business" and o.businessType != "" }
  validates :companyName, :if => lambda { |o| o.current_step == "business" and o.businessType != "" }, format: {with: /\A[a-zA-Z0-9\s]{0,35}\Z/, message: "can only contain alpha numeric characters and be no longer than 35 characters"}
  validates_presence_of :individualsType, :if => lambda { |o| o.current_step == "business" and o.businessType == "organisationOfIndividuals" }
  validates_presence_of :publicBodyType, :if => lambda { |o| o.current_step == "business" and o.businessType == "publicBody" }
  validates :publicBodyTypeOther, :if => lambda { |o| o.current_step == "business" and o.businessType == "publicBody" and o.publicBodyType == "other"}, format: {with: /\A[a-zA-Z0-9\s]{0,35}\Z/, message: "can only contain alpha numeric characters and be no longer than 35 characters"}
  validates_presence_of :publicBodyTypeOther, :if => lambda { |o| o.current_step == "business" and o.businessType == "publicBody" and o.publicBodyType == "other"}

  validates_presence_of :houseNumber, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
  validates :houseNumber ,:if => lambda { |o| o.current_step == "contact" and o.uprn == ""}, format: {with: /\A[0-9]{0,4}\Z/, message: "can only contain numbers (maximum four)"}
  validates_presence_of :postcode, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
  validates :postcode,:if => lambda { |o| o.current_step == "contact" and o.uprn == ""}, format:{with: /\A(GIR 0AA)|((([A-Z-[QVX]][0-9][0-9]?)|(([A-Z-[QVX]][A-Z-[IJZ]][0-9][0-9]?)|(([A-Z-[QVX]][0-9][A-HJKSTUW])|([A-Z-[QVX]][A-Z-[IJZ]][0-9][ABEHMNPRVWXY])))) [0-9][A-Z-[CIKMOV]]{2})\Z/, message:"must be a valid UK postcode"}
  validates_presence_of :title, :if => lambda { |o| o.current_step == "contact" }
  validates_presence_of :firstName, :if => lambda { |o| o.current_step == "contact" }
  validates :firstName, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A[a-zA-Z]*\Z/, message:"can only contain letters"}
  validates :firstName, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A.{0,35}\Z/, message:"can not be longer than 35 characters"}
  validates_presence_of :lastName, :if => lambda { |o| o.current_step == "contact" }
  validates :lastName, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A[a-zA-Z]*\Z/, message:"can only contain letters"}
  validates :lastName, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A.{0,35}\Z/, message:"can not be longer than 35 characters"}
  validates_presence_of :email, :if => lambda { |o| o.current_step == "contact" }
  validates :email, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+\Z/, message:"must be a valid email address"}
  validates :email, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A.{0,70}\Z/, message:"can not be longer than 70 characters"}
  validates_presence_of :phoneNumber, :if => lambda { |o| o.current_step == "contact" }
  validates :phoneNumber, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A[0-9\s]*\Z/, message:"can only contain numbers"}

  validates :declaration, :acceptance => "1", :if => lambda { |o| o.current_step == "confirmation" }


  def current_step
    @current_step || steps.first
  end

  def steps
    %w[business contact confirmation]
  end

  def next_step
    self.current_step = steps[steps.index(current_step)+1]
  end

  def previous_step
    self.current_step = steps[steps.index(current_step)-1]
  end

  def first_step?
    current_step == steps.first
  end

  def first_step
    steps.first
  end

  def last_step?
    current_step == steps.last
  end

  def all_valid?
    steps.all? do |step|
      self.current_step = step
      valid?
    end
  end

end
