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
    string :position
    string :phoneNumber
    string :contactEmail
    string :accountEmail
    string :declaration
    string :regIdentifier
    string :status
    # TODO: Determine if this is needed?
    string :uprn
    string :address

    string :accountEmail_confirmation
    string :password
    string :password_confirmation
    string :sign_up_mode
    string :routeName
    string :accessCode
  end

  #(Enumeration) available business types: configurable in config file
  #  %w[soleTrader partnership limitedCompany charity collectionAuthority disposalAuthority regulationAuthority other]
  BUSINESS_TYPES = Rails.application.config.registration_business_types


  TITLES = %w[mr mrs miss ms dr other]

  VALID_CHARACTERS = /\A[A-Za-z0-9\s\'\.&!%]*\Z/

  validates_presence_of :businessType, :if => lambda { |o| o.current_step == "business" }
  validates :businessType, :inclusion => { :in => BUSINESS_TYPES, :message => I18n.t('errors.messages.invalid_selection') }, :if => lambda { |o| o.current_step == "business" }
  validates_presence_of :companyName, :if => lambda { |o| o.current_step == "business" }
  validates :companyName, :if => lambda { |o| o.current_step == "business"}, format: {with: /\A[a-zA-Z0-9\s\.\-&\']{0,70}\Z/, message: I18n.t('errors.messages.alpha70') }  
  
  # TODO: FIX this Test All routes!! IS this needed
  #validates_presence_of :routeName, :if => lambda { |o| o.current_step == "business" }

  validates_presence_of :houseNumber, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
  validates :houseNumber, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}, format: {with: /\A[a-zA-Z0-9\s]{0,35}\Z/, message: I18n.t('errors.messages.lettersSpacesNumbers35') }
  validates_presence_of :streetLine1, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
  validates :streetLine1, format: {with: VALID_CHARACTERS, message: I18n.t('errors.messages.invalid_characters') }, :if => lambda { |o| o.current_step == "contact"}
  validates :streetLine2, format: {with: VALID_CHARACTERS, message: I18n.t('errors.messages.invalid_characters') }, :if => lambda { |o| o.current_step == "contact"}
  validates_length_of :streetLine1, :maximum => 35, :allow_blank => true, message: I18n.t('errors.messages.maxlength35'), :if => lambda { |o| o.current_step == "contact"}
  validates_length_of :streetLine2, :maximum => 35, :allow_blank => true, message: I18n.t('errors.messages.maxlength35'), :if => lambda { |o| o.current_step == "contact"}

  validates_presence_of :townCity, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
  validates :townCity, format: {with: VALID_CHARACTERS, message: I18n.t('errors.messages.invalid_characters') }, :if => lambda { |o| o.current_step == "contact"}
  validates_presence_of :postcode, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
  validate :validate_postcode, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
  validates_presence_of :title, :if => lambda { |o| o.current_step == "contact" }
  validates :title, :inclusion => { :in => TITLES, :message => I18n.t('errors.messages.invalid_selection') }, :if => lambda { |o| o.current_step == "contact" }

  validates_presence_of :otherTitle, :if => lambda { |o| o.current_step == "contact" and o.title == "Other"}
  validates :otherTitle, format: {with: VALID_CHARACTERS, message: I18n.t('errors.messages.invalid_characters') }, :if => lambda { |o| o.current_step == "contact"}

  validates_presence_of :firstName, :if => lambda { |o| o.current_step == "contact" }
  validates :firstName, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A[a-zA-Z\s\-\']*\Z/, message:I18n.t('errors.messages.letters') }
  validates :firstName, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A.{0,35}\Z/, message:I18n.t('errors.messages.35characters') }
  validates_presence_of :lastName, :if => lambda { |o| o.current_step == "contact" }
  validates :lastName, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A[a-zA-Z\s\-\']*\Z/, message:I18n.t('errors.messages.letters') }
  validates :lastName, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A.{0,35}\Z/, message:I18n.t('errors.messages.35characters') }
  validates :position, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A[a-zA-Z\s]*\Z/, message:I18n.t('errors.messages.lettersSpaces') }
  validates_presence_of :contactEmail, :if => lambda { |o| o.current_step == "contact" && o.routeName == 'DIGITAL'}
  validates :contactEmail, :if => lambda { |o| o.current_step == "contact" && o.routeName == 'DIGITAL'}, format:{with:/\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\Z/, message:I18n.t('errors.messages.invalidEmail') }
  validates :contactEmail, :if => lambda { |o| o.current_step == "contact" && o.routeName == 'DIGITAL'}, format:{with:/\A.{0,70}\Z/, message:I18n.t('errors.messages.70characters') }
  
  validates_presence_of :accountEmail, :if => lambda { |o| o.current_step == "signup" && o.sign_up_mode != "" }
  validates :accountEmail, :if => lambda { |o| o.current_step == "signup" && o.sign_up_mode != "" }, format:{with:/\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\Z/, message:I18n.t('errors.messages.invalidEmail') }
  validates :accountEmail, :if => lambda { |o| o.current_step == "signup" && o.sign_up_mode != "" }, format:{with:/\A.{0,70}\Z/, message:I18n.t('errors.messages.70characters') }
  
  
  
  validates_presence_of :phoneNumber, :if => lambda { |o| o.current_step == "contact" }
  validates :phoneNumber, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A[0-9\s]*\Z/, message:I18n.t('errors.messages.numbers') }
  validates_length_of :phoneNumber, :maximum => 20, :allow_blank => true, message: I18n.t('errors.messages.maxlength20'), :if => lambda { |o| o.current_step == "contact"}

  validates :declaration, :if => lambda { |o| o.current_step == "confirmation" }, format:{with:/\A1\Z/,message:I18n.t('errors.messages.accepted') }

  #Note: there is no uniqueness validation ot ouf the box in ActiveResource - only in ActiveRecord. Therefore validating with custom method.
  validate :validate_email_unique, :if => lambda { |o| o.current_step == "signup" && do_sign_up? && !o.persisted? }

  validates_presence_of :password, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode != ""}
  
  #If changing mim and max length, please also change in devise.rb
  validates_length_of :password, :minimum => 8, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode != ""}, message:I18n.t('errors.messages.min8')
  validates_length_of :password, :maximum => 128, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode != ""}, message:I18n.t('errors.messages.max128')
  validate :validate_password_strength, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode != ""}
  validate :validate_passwords, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode != ""}
  validate :validate_login, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode != ""}
  validate :validate_email_confirmation, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode != ""}
  
  #validates_presence_of :sign_up_mode, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && !o.accountEmail.nil? }
  #validates :sign_up_mode, :if => lambda { |o| o.current_step == "signup" && !o.persisted? }, :inclusion => {:in => %w[sign_up sign_in] }

  validates_presence_of :password_confirmation, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode == "sign_up" }


  def self.business_type_options_for_select
    [[I18n.t('please_select'), ""]] + (BUSINESS_TYPES.collect {|d| [I18n.t('business_types.'+d), d]})
  end

  def self.title_options_for_select
    [[I18n.t('please_select'), ""]] + (TITLES.collect {|d| [I18n.t('titles.'+d), d]})
  end

  #def sign_up_mode
  #  @sign_up_mode || 'sign_up'
  #end 

  def initialize_sign_up_mode(userEmail, signedIn)
    Rails.logger.debug "Entering initialize_sign_up_mode"
    if signedIn
      Rails.logger.debug "User already signed in with email = " + userEmail + "."
      sign_up_mode = ''
    else
      if User.where(email: userEmail).count == 0
        Rails.logger.debug "No user found in database with email = " + userEmail + ". Signing up..."
        sign_up_mode = 'sign_up'
      else
        Rails.logger.debug "Found user with email = " + userEmail + ". Directing to Sign in..."
        sign_up_mode = 'sign_in'
      end
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

  def validate_postcode
    if !Postcode.is_valid_postcode?(postcode)
      errors.add(:postcode, I18n.t('errors.messages.invalid') )
    end
  end

  def validate_email_unique
    Rails.logger.debug "entering validate_email_unique"
    if do_sign_up?
      Rails.logger.debug "validate_email_unique - do_sign_up is true"
      unless User.where(email: accountEmail).count == 0
        Rails.logger.debug "adding error - email already taken"
        errors.add(:accountEmail, I18n.t('errors.messages.emailTaken') )
      end
    end
  end

  def validate_passwords
    if !persisted? && do_sign_up?
      #Note: this method may be called (again?) after the password properties have been deleted
      if password != nil && password_confirmation != nil
        if password != password_confirmation
          errors.add(:password_confirmation, I18n.t('errors.messages.matchPassword') )
        end
      end
    else
      Rails.logger.debug "validate_passwords: not validating, sign_up_mode = " + (sign_up_mode || '')
    end
  end

  def validate_email_confirmation
    if !persisted? && do_sign_up?
      #Note: this method may be called (again?) after the password properties have been deleted
      if accountEmail != nil && accountEmail_confirmation != nil
        if accountEmail != accountEmail_confirmation
          errors.add(:accountEmail_confirmation, I18n.t('errors.messages.matchEmail') )
        end
      end
    end
  end

  def validate_password_strength
    strength = PasswordStrength.test(accountEmail,password)
    if !strength.valid?(:good)
      errors.add(:password, I18n.t('errors.messages.weakPassword') )
    end 
  end
    
  def validate_login
    Rails.logger.debug "entering validate_login"
    if !persisted? && do_sign_in?
      Rails.logger.debug "validate_login - do_sign_in is true - looking for User with this email"
      @user = User.find_by_email(accountEmail)
      if @user == nil || !@user.valid_password?(password)
        errors.add(:password, 'Invalid email and/or password')
        Rails.logger.debug "Invalid User Found"
      end
    else
      Rails.logger.debug "validate_login: not validating, sign_up_mode = " + (sign_up_mode || '')
    end
  end

  def do_sign_in?
    Rails.logger.debug "do_sign_in? - sign_up_mode = " + (sign_up_mode || '')
    'sign_in' == sign_up_mode
  end

  def do_sign_up?
    Rails.logger.debug "do_sign_up? - sign_up_mode = " + (sign_up_mode || '')
    'sign_up' == sign_up_mode
  end

  def user
    @user
  end

  def title_for_display
    if title == 'Other'
      otherTitle
    else
      I18n.translate('titles.' + title)
    end
  end  

  def generate_random_access_code
    accessCode = (0...6).map { (65 + SecureRandom.random_number(26)).chr }.join
  end  

  def assisted_digital?
    metaData && metaData.route == 'ASSISTED_DIGITAL'
  end

end
