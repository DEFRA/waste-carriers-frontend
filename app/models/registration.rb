require 'active_resource'

class Registration < ActiveResource::Base
# Note: In Rails 4, attr_accessible has been replaced by strong parameters in controllers
#  attr_accessible :address, :email, :firstName, :houseNumber, :individualsType, :lastName, :companyName, :businessType, :phoneNumber, :postcode, :publicBodyType, :registerAs, :title, :uprn, :publicBodyTypeOther, :streetLine1, :streetLine2, :townCity, :declaration

  #The services URL can be configured in config/application.rb and/or in the config/environments/*.rb files.
  self.site = Rails.configuration.waste_exemplar_services_url

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
    string :postcodeSearch
    string :title
    string :otherTitle
    string :firstName
    string :lastName
    string :phoneNumber
    string :email
    string :declaration
    string :regIdentifier
    # TODO: Determine if this is needed?
    string :uprn
    string :address

    string :password
    string :password_confirmation
    string :sign_up_mode
  end

  validates_presence_of :businessType, :if => lambda { |o| o.current_step == "business" }
  validates_presence_of :companyName, :if => lambda { |o| o.current_step == "business" }
  validates :companyName, :if => lambda { |o| o.current_step == "business"}, format: {with: /\A[a-zA-Z0-9\s\.&]{0,35}\Z/, message: "can only contain alpha numeric characters and be no longer than 35 characters"}
  
  validates_presence_of :houseNumber, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
  validates :houseNumber ,:if => lambda { |o| o.current_step == "contact" and o.uprn == ""}, format: {with: /\A[0-9]{0,4}\Z/, message: "can only contain numbers (maximum four)"}
  validates_presence_of :postcode, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
  validates_presence_of :title, :if => lambda { |o| o.current_step == "contact" }
  validates_presence_of :otherTitle, :if => lambda { |o| o.current_step == "contact" and o.title == "Other"}
  validates_presence_of :firstName, :if => lambda { |o| o.current_step == "contact" }
  validates :firstName, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A[a-zA-Z]*\Z/, message:"can only contain letters"}
  validates :firstName, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A.{0,35}\Z/, message:"can not be longer than 35 characters"}
  validates_presence_of :lastName, :if => lambda { |o| o.current_step == "contact" }
  validates :lastName, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A[a-zA-Z]*\Z/, message:"can only contain letters"}
  validates :lastName, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A.{0,35}\Z/, message:"can not be longer than 35 characters"}
  validates_presence_of :email, :if => lambda { |o| o.current_step == "contact" }
  validates :email, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\Z/, message:"must be a valid email address"}
  validates :email, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A.{0,70}\Z/, message:"can not be longer than 70 characters"}
  validates_presence_of :phoneNumber, :if => lambda { |o| o.current_step == "contact" }
  validates :phoneNumber, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A[0-9\s]*\Z/, message:"can only contain numbers"}

  validates :declaration, :if => lambda { |o| o.current_step == "confirmation" }, format:{with:/\A1\Z/,message:"must be accepted"}

  #Note: there is no uniqueness validation ot ouf the box in ActiveResource - only in ActiveRecord. Therefore validating with custom method.
  validate :validate_email_unique, :if => lambda { |o| o.current_step == "signup" && do_sign_up?}

  validates_presence_of :password, :if => lambda { |o| o.current_step == "signup" }
  #If changing mim and max length, please also change in devise.rb
  validates_length_of :password, :minimum => 8, :maximum => 128, :if => lambda { |o| o.current_step == "signup" }
  validate :validate_passwords, :if => lambda { |o| o.current_step == "signup" }
  validate :validate_login, :if => lambda { |o| o.current_step == "signup" }
  validates_presence_of :sign_up_mode, :if => lambda { |o| o.current_step == "signup" }
  validates :sign_up_mode, :if => lambda { |o| o.current_step == "signup" }, :inclusion => {:in => %w[sign_up sign_in] }

  #def sign_up_mode
  #  @sign_up_mode || 'sign_up'
  #end 

  def initialize_sign_up_mode
    Rails.logger.debug "Entering initialize_sign_up_mode"
    if User.where(email: email).count == 0
      Rails.logger.debug "No user found in database with email = " + email + ". Signing up..."
      sign_up_mode = 'sign_up'
    else
      Rails.logger.debug "Found user with email = " + email + ". Signing in..."
      sign_up_mode = 'sign_in'
    end
  end

  def current_step
    @current_step || steps.first
  end

  def steps
    %w[business contact confirmation signup]
  end

  VALID_SIGN_UP_MODES = %w[sign_up sign_in]


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

  def confirmation_step?
    current_step == 'confirmation'
  end

  def all_valid?
    steps.all? do |step|
      self.current_step = step
      valid?
    end
  end

  def validate_email_unique
    Rails.logger.debug "entering validate_email_unique"
    if do_sign_up?
      Rails.logger.debug "validate_email_unique - do_sign_up is true"
      unless User.where(email: email).count == 0
        Rails.logger.debug "adding error - email already taken"
        errors.add(:email, 'Account for this e-mail is already taken')
      end
    end
  end

  def validate_passwords
    if do_sign_up?
      #Note: this method may be called (again?) after the password properties have been deleted
      if password != nil && password_confirmation != nil
        if password != password_confirmation
          errors.add(:password_confirmation, 'The passwords must match')
        end
      end
    else
      Rails.logger.debug "validate_passwords: not validating, sign_up_mode = " + sign_up_mode
    end
  end

  def validate_login
    Rails.logger.debug "entering validate_login"
    if do_sign_in?
      Rails.logger.debug "validate_login - do_sign_in is true - looking for User with this email"
      @user = User.find_by_email(email)
      if @user == nil || !@user.valid_password?(password)
        errors.add(:password, 'Invalid email and/or password')
      end
    else
      Rails.logger.debug "validate_login: not validating, sign_up_mode = " + sign_up_mode
    end
  end

  def do_sign_in?
    Rails.logger.debug "do_sign_in? - sign_up_mode = " + sign_up_mode
    'sign_in' == sign_up_mode
  end

  def do_sign_up?
    Rails.logger.debug "do_sign_up? - sign_up_mode = " + sign_up_mode
    'sign_up' == sign_up_mode
  end

  def user
    @user
  end

end
