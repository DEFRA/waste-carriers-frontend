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
    
    string :addressMode
    string :postcodeSearch
    string :selectedMoniker
    string :streetLine1
    string :streetLine2
    string :townCity
    string :postcode
    
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

  # Business Step fields
  validate :validate_businessType, :if => lambda { |o| o.current_step == "business" }
  validate :validate_companyName, :if => lambda { |o| o.current_step == "business" }
  # TODO: FIX this Test All routes!! IS this needed
  #validates_presence_of :routeName, :if => lambda { |o| o.current_step == "business" }

  # Contact Step fields
  validate :validate_houseNumber, :if => lambda { |o| o.current_step == "contact" and o.uprn == "" }
  validate :validate_streetLine1, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
  validate :validate_streetLine2, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
  validate :validate_townCity, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
  validate :validate_postcode, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
  
  validate :validate_title, :if => lambda { |o| o.current_step == "contact" }
  validate :validate_otherTitle, :if => lambda { |o| o.current_step == "contact" and o.title == "other"}
  validate :validate_firstName, :if => lambda { |o| o.current_step == "contact" }
  validate :validate_lastName, :if => lambda { |o| o.current_step == "contact" }
  validate :validate_position, :if => lambda { |o| o.current_step == "contact" }
  validate :validate_phoneNumber, :if => lambda { |o| o.current_step == "contact" }
  validate :validate_contactEmail, :if => lambda { |o| o.current_step == "contact" }
  
  # Confirmation fields
  validates :declaration, :if => lambda { |o| o.current_step == "confirmation" }, format:{with:/\A1\Z/,message:I18n.t('errors.messages.accepted') }
  
  # Sign up / Sign in fields
  validate :validate_accountEmail, :if => lambda { |o| o.current_step == "signup" && o.sign_up_mode != "" }
  #Note: there is no uniqueness validation out of the box in ActiveResource - only in ActiveRecord. Therefore validating with custom method.
  validate :validate_email_unique, :if => lambda { |o| o.current_step == "signup" && do_sign_up? && !o.persisted? }
  validate :validate_accountEmail_confirmation, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode == "sign_up"}
  validate :validate_password, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode != ""}
  validate :validate_password_confirmation, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode == "sign_up" }
  
  #validates_presence_of :sign_up_mode, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && !o.accountEmail.nil? }
  #validates :sign_up_mode, :if => lambda { |o| o.current_step == "signup" && !o.persisted? }, :inclusion => {:in => %w[sign_up sign_in] }

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
  
  def steps_valid?(uptostep)
    Rails.logger.debug 'steps_valid() uptostep: ' + uptostep
    steps.all? do |step|
      if steps.index(step) < steps.index(uptostep)
        Rails.logger.debug 'about to validate step: ' + step
        self.current_step = step
        valid?
      else
        # set default to true to ensure remaining steps return true
        Rails.logger.debug 'WHEN AM I CALLED'
        true
      end
    end
  end
  
  # ----------------------------------------------------------
  # FIELD VALIDATIONS
  # ----------------------------------------------------------
  def validate_businessType
    #validates_presence_of :businessType, :if => lambda { |o| o.current_step == "business" }
    if businessType == ""
      Rails.logger.debug 'businessType is empty'
      errors.add(:businessType, I18n.t('errors.messages.blank') )
    #validates :businessType, :inclusion => { :in => BUSINESS_TYPES, :message => I18n.t('errors.messages.invalid_selection') }, :if => lambda { |o| o.current_step == "business" }
    elsif !BUSINESS_TYPES.include?(businessType)
      Rails.logger.debug 'businessType not a valid value'
      errors.add(:businessType, I18n.t('errors.messages.invalid_selection') )
    end
  end
  
  def validate_companyName
    #validates_presence_of :companyName, :if => lambda { |o| o.current_step == "business" }
    if companyName == ""
      Rails.logger.debug 'companyName is empty'
      errors.add(:companyName, I18n.t('errors.messages.blank') )
    #validates :companyName, :if => lambda { |o| o.current_step == "business"}, format: {with: /\A[a-zA-Z0-9\s\.\-&\']{0,70}\Z/, message: I18n.t('errors.messages.alpha70') }  
    elsif !companyName.nil? and companyName[/\A[a-zA-Z0-9\s\.\-&\']{0,70}\Z/].nil?
      Rails.logger.debug 'companyName fails reg ex check'
      errors.add(:companyName, I18n.t('errors.messages.alpha70') )
    end
  end
  
  def validate_houseNumber
    #validates_presence_of :houseNumber, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
    if houseNumber == ""
      Rails.logger.debug 'houseNumber is empty'
      errors.add(:houseNumber, I18n.t('errors.messages.blank') )
    #validates :houseNumber, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}, format: {with: /\A[a-zA-Z0-9\s]{0,35}\Z/, message: I18n.t('errors.messages.lettersSpacesNumbers35') }
    elsif !houseNumber.nil? and houseNumber[/\A[a-zA-Z0-9\s]{0,35}\Z/].nil?
      Rails.logger.debug 'houseNumber fails reg ex check'
      errors.add(:houseNumber, I18n.t('errors.messages.lettersSpacesNumbers35') )
    end
  end
  
  def validate_streetLine1
    #validates_presence_of :streetLine1, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
    if streetLine1 == ""
      Rails.logger.debug 'streetLine1 is empty'
      errors.add(:streetLine1, I18n.t('errors.messages.blank') )
    #validates :streetLine1, format: {with: VALID_CHARACTERS, message: I18n.t('errors.messages.invalid_characters') }, :if => lambda { |o| o.current_step == "contact"}
    elsif !streetLine1.nil? and streetLine1[VALID_CHARACTERS].nil?
      Rails.logger.debug 'streetLine1 fails reg ex check'
      errors.add(:streetLine1, I18n.t('errors.messages.invalid_characters') )
    #validates_length_of :streetLine1, :maximum => 35, :allow_blank => true, message: I18n.t('errors.messages.maxlength35'), :if => lambda { |o| o.current_step == "contact"}
    elsif !streetLine1.nil? and streetLine1.length > 35
      Rails.logger.debug 'streetLine1 longer than allowed'
      errors.add(:streetLine1, I18n.t('errors.messages.maxlength35') )
    end
  end
  
  def validate_streetLine2
    #validates :streetLine2, format: {with: VALID_CHARACTERS, message: I18n.t('errors.messages.invalid_characters') }, :if => lambda { |o| o.current_step == "contact"}
    if !streetLine2.nil? and streetLine2[VALID_CHARACTERS].nil?
      Rails.logger.debug 'streetLine2 fails reg ex check'
      errors.add(:streetLine2, I18n.t('errors.messages.invalid_characters') )
    #validates_length_of :streetLine2, :maximum => 35, :allow_blank => true, message: I18n.t('errors.messages.maxlength35'), :if => lambda { |o| o.current_step == "contact"}
    elsif !streetLine2.nil? and streetLine2.length > 35
      Rails.logger.debug 'streetLine2 longer than allowed'
      errors.add(:streetLine2, I18n.t('errors.messages.maxlength35') )
    end
  end
  
  def validate_townCity
    #validates_presence_of :townCity, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
    if townCity == ""
      Rails.logger.debug 'townCity is empty'
      errors.add(:townCity, I18n.t('errors.messages.blank') )
    #validates :townCity, format: {with: VALID_CHARACTERS, message: I18n.t('errors.messages.invalid_characters') }, :if => lambda { |o| o.current_step == "contact"}
    elsif !townCity.nil? and townCity[VALID_CHARACTERS].nil?
      Rails.logger.debug 'townCity fails reg ex check'
      errors.add(:townCity, I18n.t('errors.messages.invalid_characters') )
    end
  end

  def validate_postcode
    #validates_presence_of :postcode, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
    if postcode == ""
      Rails.logger.debug 'postcode is empty'
      errors.add(:postcode, I18n.t('errors.messages.blank') )
    elsif !Postcode.is_valid_postcode?(postcode)
      errors.add(:postcode, I18n.t('errors.messages.invalid') )
    end
  end
  
  def validate_title
    #validates_presence_of :title, :if => lambda { |o| o.current_step == "contact" }
    if title == ""
      Rails.logger.debug 'title is empty'
      errors.add(:title, I18n.t('errors.messages.blank') )
    #validates :title, :inclusion => { :in => TITLES, :message => I18n.t('errors.messages.invalid_selection') }, :if => lambda { |o| o.current_step == "contact" }
    elsif !TITLES.include?(title)
      Rails.logger.debug 'title not a valid value'
      errors.add(:title, I18n.t('errors.messages.invalid_selection') )
    end
  end
  
  def validate_otherTitle
    #validates_presence_of :otherTitle, :if => lambda { |o| o.current_step == "contact" and o.title == "other"}
    if otherTitle == ""
      Rails.logger.debug 'otherTitle is empty'
      errors.add(:otherTitle, I18n.t('errors.messages.blank') )
    #validates :otherTitle, format: {with: VALID_CHARACTERS, message: I18n.t('errors.messages.invalid_characters') }, :if => lambda { |o| o.current_step == "contact"}
    elsif !otherTitle.nil? and otherTitle[VALID_CHARACTERS].nil?
      Rails.logger.debug 'otherTitle fails reg ex check'
      errors.add(:otherTitle, I18n.t('errors.messages.invalid_characters') )
    end
  end
  
  def validate_firstName
    #validates_presence_of :firstName, :if => lambda { |o| o.current_step == "contact" }
    if firstName == ""
      Rails.logger.debug 'firstName is empty'
      errors.add(:firstName, I18n.t('errors.messages.blank') )
    #validates :firstName, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A[a-zA-Z\s\-\']*\Z/, message:I18n.t('errors.messages.letters') }
    elsif !firstName.nil? and firstName[/\A[a-zA-Z\s\-\']*\Z/].nil?
      Rails.logger.debug 'firstName fails reg ex check'
      errors.add(:firstName, I18n.t('errors.messages.letters') )
    #validates :firstName, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A.{0,35}\Z/, message:I18n.t('errors.messages.35characters') }
    elsif !firstName.nil? and firstName[/\A.{0,35}\Z/].nil?
      Rails.logger.debug 'firstName fails reg ex check'
      errors.add(:firstName, I18n.t('errors.messages.35characters') )
    end
  end
  
  def validate_lastName
    #validates_presence_of :lastName, :if => lambda { |o| o.current_step == "contact" }
    if lastName == ""
      Rails.logger.debug 'lastName is empty'
      errors.add(:lastName, I18n.t('errors.messages.blank') )
    #validates :lastName, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A[a-zA-Z\s\-\']*\Z/, message:I18n.t('errors.messages.letters') }
    elsif !lastName.nil? and lastName[/\A[a-zA-Z\s\-\']*\Z/].nil?
      Rails.logger.debug 'lastName fails reg ex check'
      errors.add(:lastName, I18n.t('errors.messages.letters') )
    #validates :lastName, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A.{0,35}\Z/, message:I18n.t('errors.messages.35characters') }
    elsif !lastName.nil? and lastName[/\A.{0,35}\Z/].nil?
      Rails.logger.debug 'lastName fails reg ex check'
      errors.add(:lastName, I18n.t('errors.messages.35characters') )
    end
  end
  
  def validate_position
    #validates :position, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A[a-zA-Z\s]*\Z/, message:I18n.t('errors.messages.lettersSpaces') }
    if !position.nil? and position[/\A[a-zA-Z\s]*\Z/].nil?
      Rails.logger.debug 'position fails reg ex check'
      errors.add(:position, I18n.t('errors.messages.lettersSpaces') )
    end
  end
  
  def validate_phoneNumber
    #validates_presence_of :phoneNumber, :if => lambda { |o| o.current_step == "contact" }
    if phoneNumber == ""
      Rails.logger.debug 'phoneNumber is empty'
      errors.add(:phoneNumber, I18n.t('errors.messages.blank') )
    #validates :phoneNumber, :if => lambda { |o| o.current_step == "contact" }, format:{with:/\A[0-9\s]*\Z/, message:I18n.t('errors.messages.numbers') }
    elsif !phoneNumber.nil? and phoneNumber[/\A[0-9\s]*\Z/].nil?
      Rails.logger.debug 'phoneNumber fails reg ex check'
      errors.add(:phoneNumber, I18n.t('errors.messages.numbers') )
    #validates_length_of :phoneNumber, :maximum => 20, :allow_blank => true, message: I18n.t('errors.messages.maxlength20'), :if => lambda { |o| o.current_step == "contact"}
    elsif !phoneNumber.nil? and phoneNumber.length > 20
      Rails.logger.debug 'phoneNumber longer than allowed'
      errors.add(:phoneNumber, I18n.t('errors.messages.maxlength20') )
    end
  end
  
  def validate_contactEmail
    #validates_presence_of :contactEmail, :if => lambda { |o| o.current_step == "contact" && o.routeName == 'DIGITAL'}
    if contactEmail == "" and routeName == 'DIGITAL'
      Rails.logger.debug 'contactEmail is empty'
      errors.add(:contactEmail, I18n.t('errors.messages.blank') )
    #validates :contactEmail, :if => lambda { |o| o.current_step == "contact" && o.routeName == 'DIGITAL'}, format:{with:/\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\Z/, message:I18n.t('errors.messages.invalidEmail') }
    elsif !contactEmail.nil? and !contactEmail.empty? and contactEmail[/\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\Z/].nil?
      Rails.logger.debug 'contactEmail fails reg ex check 1'
      errors.add(:contactEmail, I18n.t('errors.messages.invalidEmail') )
    #validates :contactEmail, :if => lambda { |o| o.current_step == "contact" && o.routeName == 'DIGITAL'}, format:{with:/\A.{0,70}\Z/, message:I18n.t('errors.messages.70characters') }
    elsif !contactEmail.nil? and contactEmail[/\A.{0,70}\Z/].nil?
      Rails.logger.debug 'contactEmail fails reg ex check 2'
      errors.add(:contactEmail, I18n.t('errors.messages.70characters') )
    end
  end
  
  def validate_accountEmail
    #validates_presence_of :accountEmail, :if => lambda { |o| o.current_step == "signup" && o.sign_up_mode != "" }
    if accountEmail == ""
      Rails.logger.debug 'accountEmail is empty'
      errors.add(:accountEmail, I18n.t('errors.messages.blank') )
    #validates :accountEmail, :if => lambda { |o| o.current_step == "signup" && o.sign_up_mode != "" }, format:{with:/\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\Z/, message:I18n.t('errors.messages.invalidEmail') }
    elsif !accountEmail.nil? and accountEmail[/\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\Z/].nil?
      Rails.logger.debug 'accountEmail fails reg ex check'
      errors.add(:accountEmail, I18n.t('errors.messages.invalidEmail') )
    #validates :accountEmail, :if => lambda { |o| o.current_step == "signup" && o.sign_up_mode != "" }, format:{with:/\A.{0,70}\Z/, message:I18n.t('errors.messages.70characters') }
    elsif !accountEmail.nil? and accountEmail[/\A.{0,70}\Z/].nil?
      Rails.logger.debug 'accountEmail fails reg ex check'
      errors.add(:accountEmail, I18n.t('errors.messages.70characters') )
    end
  end
  
  def validate_password
    #validates_presence_of :password, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode != ""}
    if password == ""
      Rails.logger.debug 'password is empty'
      errors.add(:password, I18n.t('errors.messages.blank') )
    #If changing mim and max length, please also change in devise.rb
    #validates_length_of :password, :minimum => 8, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode != ""}, message:I18n.t('errors.messages.min8')
    elsif !password.nil? and password.length < 8
      Rails.logger.debug 'password minimum not reached'
      errors.add(:password, I18n.t('errors.messages.min8') )
    #validates_length_of :password, :maximum => 128, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode != ""}, message:I18n.t('errors.messages.max128')
    elsif !password.nil? and password.length > 128
      Rails.logger.debug 'password longer than allowed'
      errors.add(:password, I18n.t('errors.messages.max128') )
    else
      #validate :validate_password_strength, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode != ""}
      strength = PasswordStrength.test(accountEmail,password)
      if !password.nil? and !strength.valid?(:good)
        errors.add(:password, I18n.t('errors.messages.weakPassword') )
      else
	    if !persisted? && do_sign_in?
	      Rails.logger.debug "validate_password - do_sign_in is true - looking for User with this email"
	      @user = User.find_by_email(accountEmail)
	      if @user == nil || !@user.valid_password?(password)
	        errors.add(:password, 'Invalid email and/or password')
	        Rails.logger.debug "Invalid User Found"
	      end
	    else
	      Rails.logger.debug "validate_password: not validating, sign_up_mode = " + (sign_up_mode || '')
	    end
      end 
    end
  end
  
  def validate_password_confirmation
    #validates_presence_of :password_confirmation, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode == "sign_up" }
    if password_confirmation == ""
      Rails.logger.debug 'password_confirmation is empty'
      errors.add(:password_confirmation, I18n.t('errors.messages.blank') )
    #validate :validate_passwords, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode != ""}
    elsif !persisted? && do_sign_up?
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
  
  # ----------------------------------------------------------
  # GENERAL VALIDATIONS
  # ----------------------------------------------------------

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

  def validate_accountEmail_confirmation
    if !persisted? && do_sign_up?
      #Note: this method may be called (again?) after the password properties have been deleted
      if accountEmail != nil && accountEmail_confirmation != nil
        if accountEmail != accountEmail_confirmation
          errors.add(:accountEmail_confirmation, I18n.t('errors.messages.matchEmail') )
        end
      end
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
    if title == 'other'
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
