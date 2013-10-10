class Registration < ActiveRecord::Base
  attr_accessible :address, :companyRegistrationNumber, :emailAddress, :firstName, :houseNumber, :individualsType, :lastName, :organisationName, :organisationType, :phoneNumber, :postcode, :publicBodyType, :registerAs, :title, :uprn, :publicBodyOther, :address1, :address2, :city, :declaration

  attr_writer :current_step

  validates_presence_of :organisationType, :if => lambda { |o| o.current_step == "business" }
  validates_presence_of :organisationName, :if => lambda { |o| o.current_step == "business" and o.organisationType != "" }
  validates :organisationName, :if => lambda { |o| o.current_step == "business" and o.organisationType != "" }, format: {with: /\A[a-zA-Z0-9\s]{0,35}\Z/, message: "can only contain alpha numeric characters and be no longer than 35 characters"}
  validates_presence_of :individualsType, :if => lambda { |o| o.current_step == "business" and o.organisationType == "organisationOfIndividuals" }
  validates_presence_of :publicBodyType, :if => lambda { |o| o.current_step == "business" and o.organisationType == "publicBody" }
  validates :publicBodyOther, :if => lambda { |o| o.current_step == "business" and o.organisationType == "publicBody" and o.publicBodyType == "other"}, format: {with: /\A[a-zA-Z0-9\s]{0,35}\Z/, message: "can only contain alpha numeric characters and be no longer than 35 characters"}
  validates_presence_of :publicBodyOther, :if => lambda { |o| o.current_step == "business" and o.organisationType == "publicBody" and o.publicBodyType == "other"}

  validates_presence_of :houseNumber, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
  validates :houseNumber ,:if => lambda { |o| o.current_step == "contact" and o.uprn == ""}, format: {with: /\A[0-9]{0,4}\Z/, message: "can only contain numbers (maximum four)"}
  validates_presence_of :postcode, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
  validates :postcode,:if => lambda { |o| o.current_step == "contact" and o.uprn == ""}, format:{with: /\A(GIR 0AA)|((([A-Z-[QVX]][0-9][0-9]?)|(([A-Z-[QVX]][A-Z-[IJZ]][0-9][0-9]?)|(([A-Z-[QVX]][0-9][A-HJKSTUW])|([A-Z-[QVX]][A-Z-[IJZ]][0-9][ABEHMNPRVWXY])))) [0-9][A-Z-[CIKMOV]]{2})\Z/, message:"must be a valid UK postcode"}
  validates_presence_of :title, :if => lambda { |o| o.current_step == "contact" }
  validates_presence_of :firstName, :if => lambda { |o| o.current_step == "contact" }
  validates_presence_of :lastName, :if => lambda { |o| o.current_step == "contact" }
  validates_presence_of :emailAddress, :if => lambda { |o| o.current_step == "contact" }
  validates_presence_of :phoneNumber, :if => lambda { |o| o.current_step == "contact" }

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
