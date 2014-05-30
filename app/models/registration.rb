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
    string :otherBusinesses
    string :isMainService
    string :constructionWaste
    string :onlyAMF
    string :companyName
    string :individualsType
    string :publicBodyType
    string :publicBodyTypeOther
    string :registrationType
    string :houseNumber

    string :addressMode
    string :postcodeSearch
    string :selectedMoniker
    string :streetLine1
    string :streetLine2
    string :townCity
    string :postcode
    string :easting
    string :northing
    string :dependentLocality
    string :dependentThroughfare
    string :administrativeArea
    string :royalMailUpdateDate
    string :localAuthorityUpdateDate

    # Non UK fields
    string :streetLine3
    string :streetLine4
    string :country

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
    # upper registration attributes
    string :alt_first_name
    string :alt_last_name
    string :alt_job_title
    string :alt_telephone_number
    string :alt_email_address
    string :primary_first_name
    string :primary_last_name
    string :primary_job_title
    string :primary_telephone_number
    string :primary_email_address

    # Used as a trigger value to force validation of the revoke reason field
    # When this value contains any value, the revokeReason field is validated
    string :revoked
  end

  BUSINESS_TYPES = %w[
    soleTrader
    partnership
    limitedCompany
    publicBody
    charity
    authority
    other
  ]

  TITLES = %w[mr mrs miss ms dr other]

  VALID_CHARACTERS = /\A[A-Za-z0-9\s\'\.&!%]*\Z/

  DISTANCES = %w[any 10 50 100]
  POSTCODE_CHARACTERS = /\A[A-Za-z0-9\s]*\Z/
  YES_NO_ANSWER = %w(yes no)
  VALID_EMAIL_REGEX = Devise.email_regexp

  validates :businessType, presence: true, inclusion: { in: BUSINESS_TYPES }, if: :businesstype_step?
  validates :otherBusinesses, presence: true, inclusion: { in: YES_NO_ANSWER }, if: :otherbusinesses_step?
  validates :isMainService, presence: true, inclusion: { in: YES_NO_ANSWER }, if: :serviceprovided_step?
  validates :constructionWaste, presence: true, inclusion: { in: YES_NO_ANSWER }, if: :constructiondemolition_step?
  validates :onlyAMF, presence: true, inclusion: { in: YES_NO_ANSWER }, if: :onlydealwith_step?

  validates :companyName, presence: true, format: { with: /\A[a-zA-Z0-9\s\.\-&\']{0,70}\z/, message: I18n.t('errors.messages.alpha70') }, if: :businessdetails_step?

  with_options if: :contactdetails_step? do |registration|
    registration.validates :firstName, presence: true, format: { with: /\A[a-zA-Z\s\-\']*\z/ }
    registration.validates :lastName, presence: true, format: { with: /\A[a-zA-Z\s\-\']*\z/ }
    registration.validates :position, presence: true, format: { with: /\A[a-zA-Z\s\-\']*\z/ }
    registration.validates :phoneNumber, presence: true, format: { with: /\A[0-9-+()\s]*\z/ }
    registration.validates :contactEmail, presence: true, format: { with: VALID_EMAIL_REGEX }
  end

  with_options if: :signup_step? do |registration|
    registration.validates :accountEmail, presence: true, format: { with: VALID_EMAIL_REGEX }
    registration.validates :accountEmail_confirmation, presence: true, format: { with: VALID_EMAIL_REGEX }
    registration.validates :password, presence: true
    registration.validates_strength_of [:password, :password_confirmation], with: :accountEmail
    registration.validates :password_confirmation, presence: true
  end

  def businesstype_step?
    current_step.inquiry.businesstype?
  end

  def otherbusinesses_step?
    current_step.inquiry.otherbusinesses?
  end

  def serviceprovided_step?
    current_step.inquiry.serviceprovided?
  end

  def constructiondemolition_step?
    current_step.inquiry.constructiondemolition?
  end

  def onlydealwith_step?
    current_step.inquiry.onlydealwith?
  end

  def businessdetails_step?
    current_step.inquiry.businessdetails?
  end

  def contactdetails_step?
    current_step.inquiry.contactdetails?
  end

  def signup_step?
    current_step.inquiry.signup?
  end

  # Business Step fields
  # validate :validate_businessType, :if => lambda { |o| o.current_step == "business" }
  # validate :validate_companyName, :if => lambda { |o| o.current_step == "business" }
  # TODO: FIX this Test All routes!! IS this needed
  #validates_presence_of :routeName, :if => lambda { |o| o.current_step == "business" }

  # Contact Step fields
=begin
  validate :validate_houseNumber, :if => lambda { |o| o.current_step == "contact" and o.addressMode == "manual-uk"}
  validate :validate_streetLine1, :if => lambda { |o| o.current_step == "contact" and o.addressMode}
  validate :validate_streetLine2, :if => lambda { |o| o.current_step == "contact" and o.addressMode}
  validate :validate_streetLine3, :if => lambda { |o| o.current_step == "contact" and o.addressMode == "manual-foreign"}
  validate :validate_streetLine4, :if => lambda { |o| o.current_step == "contact" and o.addressMode == "manual-foreign"}
  validate :validate_country, :if => lambda { |o| o.current_step == "contact" and o.addressMode == "manual-foreign"}
  validate :validate_townCity, :if => lambda { |o| o.current_step == "contact" and o.addressMode == "manual-uk"}
  validate :validate_postcode, :if => lambda { |o| o.current_step == "contact" and o.addressMode == "manual-uk"}
  validate :validate_postcodeSearch, :if => lambda { |o| o.current_step == "contact" and !o.addressMode}
  validate :validate_selectedMoniker, :if => lambda { |o| o.current_step == "contact" and !o.addressMode}
=end
  
  # validate :validate_addressMode
  
  # validate :validate_title, :if => lambda { |o| o.current_step == "contact" }
  # validate :validate_otherTitle, :if => lambda { |o| o.current_step == "contact" and o.title == "other"}
  # validate :validate_firstName, :if => lambda { |o| o.current_step == "contact" }
  # validate :validate_lastName, :if => lambda { |o| o.current_step == "contact" }
  # validate :validate_position, :if => lambda { |o| o.current_step == "contact" }
  # validate :validate_phoneNumber, :if => lambda { |o| o.current_step == "contact" }
  # validate :validate_contactEmail, :if => lambda { |o| o.current_step == "contact" }
  
  # Confirmation fields
  # validates :declaration, :if => lambda { |o| o.current_step == "confirmation" }, format:{with:/\A1\Z/,message:I18n.t('errors.messages.accepted') }

  # Sign up / Sign in fields
  # validate :validate_accountEmail, :if => lambda { |o| o.current_step == "signup" && o.sign_up_mode != "" }
  #Note: there is no uniqueness validation out of the box in ActiveResource - only in ActiveRecord. Therefore validating with custom method.
  # validate :validate_email_unique, :if => lambda { |o| o.current_step == "signup" && do_sign_up? && !o.persisted? }
  # validate :validate_accountEmail_confirmation, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode == "sign_up"}
  # validate :validate_password, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode != ""}
  # validate :validate_password_confirmation, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && o.sign_up_mode == "sign_up" }

  # Validate Revoke Reason
  # validate :validate_revokedReason, :if => lambda { |o| o.persisted? }

  #validates_presence_of :sign_up_mode, :if => lambda { |o| o.current_step == "signup" && !o.persisted? && !o.accountEmail.nil? }
  #validates :sign_up_mode, :if => lambda { |o| o.current_step == "signup" && !o.persisted? }, :inclusion => {:in => %w[sign_up sign_in] }

  def self.business_type_options_for_select
    (BUSINESS_TYPES.collect {|d| [I18n.t('business_types.'+d), d]})
  end

  def self.title_options_for_select
    [[I18n.t('please_select'), ""]] + (TITLES.collect {|d| [I18n.t('titles.'+d), d]})
  end

  def self.distance_options_for_select
    (DISTANCES.collect {|d| [I18n.t('distances.'+d), d]})
  end

  def initialize_sign_up_mode(userEmail, signedIn)
    Rails.logger.debug "Entering initialize_sign_up_mode"
    if signedIn
      Rails.logger.debug "User already signed in with email = " + userEmail + "."
      ''
    else
      if User.where(email: userEmail).count == 0
        Rails.logger.debug "No user found in database with email = " + userEmail + ". Signing up..."
        'sign_up'
      else
        Rails.logger.debug "Found user with email = " + userEmail + ". Directing to Sign in..."
        'sign_in'
      end
    end
  end

  def current_step
    @current_step || first_step
  end

  VALID_SIGN_UP_MODES = %w[sign_up sign_in]

  def first_step
    'businesstype'
  end

  def first_step?
    current_step == first_step
  end

  def businesstype?
    current_step == 'businesstype'
  end

  def last_step?
    noregistration?
  end

  def noregistration?
    current_step == 'noregistration'
  end

  def confirmation_step?
    current_step == 'confirmation'
  end

  def all_valid?
    # TODO This needs to be properly sorted and changed to handle a branching workflow.
    # For now we simply return true.
    true
    # steps.all? do |step|
    #   self.current_step = step
    #   valid?
    # end
  end

  def steps_valid?(uptostep)
    # TODO This needs to be properly sorted and changed to handle a branching workflow.
    # For now we simply return true.
    true
    # Rails.logger.debug 'steps_valid() uptostep: ' + uptostep
    # steps.all? do |step|
    #   if steps.index(step) < steps.index(uptostep)
    #     Rails.logger.debug 'about to validate step: ' + step
    #     self.current_step = step
    #     valid?
    #   else
    #     # set default to true to ensure remaining steps return true
    #     Rails.logger.debug 'WHEN AM I CALLED'
    #     true
    #   end
    # end
  end

  def pending?
    metaData && metaData.status == 'PENDING'
  end

  def pending!
    metaData.status = 'PENDING'
  end

  def activate!
    #Note: the actual status update will be performed in the service
    metaData.status = 'ACTIVATE'
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
    if houseNumber.nil? or houseNumber == ""
      Rails.logger.debug 'houseNumber is empty'
      errors.add(:houseNumber, I18n.t('errors.messages.blank') )
    #validates :houseNumber, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}, format: {with: /\A[a-zA-Z0-9\s]{0,35}\Z/, message: I18n.t('errors.messages.lettersSpacesNumbers35') }
    elsif !houseNumber.nil? and houseNumber[/\A[a-zA-Z0-9\s-]{0,35}\Z/].nil?
      Rails.logger.debug 'houseNumber fails reg ex check'
      errors.add(:houseNumber, I18n.t('errors.messages.lettersSpacesNumbers35') )
    end
  end

  def validate_postcodeSearch
    if postcodeSearch == "" and addressMode.nil?
      errors.add(:postcodeSearch, I18n.t('errors.messages.blank') )
    end
  end

  def validate_selectedMoniker
    if (selectedMoniker.nil? or selectedMoniker == "") and addressMode.nil? and postcodeSearch != "" and !uprn
      errors.add(:selectedMoniker, I18n.t('errors.messages.blank') )
    end
  end

  def validate_addressMode
    if addressMode and !addressMode.nil? and addressMode != "manual-uk" and addressMode != "manual-foreign"
      errors.add(:addressMode, I18n.t('errors.messages.blank') )
    end
  end

  def validate_streetLine1
    #validates_presence_of :streetLine1, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
    if streetLine1.nil? or streetLine1 == ""
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

  def validate_streetLine3
    if !streetLine3.nil? and streetLine3[VALID_CHARACTERS].nil?
      Rails.logger.debug 'streetLine3 fails reg ex check'
      errors.add(:streetLine3, I18n.t('errors.messages.invalid_characters') )
    #validates_length_of :streetLine3, :maximum => 35, :allow_blank => true, message: I18n.t('errors.messages.maxlength35'), :if => lambda { |o| o.current_step == "contact"}
    elsif !streetLine3.nil? and streetLine3.length > 35
      Rails.logger.debug 'streetLine3 longer than allowed'
      errors.add(:streetLine3, I18n.t('errors.messages.maxlength35') )
    end
  end

  def validate_streetLine4
    if !streetLine4.nil? and streetLine4[VALID_CHARACTERS].nil?
      Rails.logger.debug 'streetLine4 fails reg ex check'
      errors.add(:streetLine4, I18n.t('errors.messages.invalid_characters') )
    #validates_length_of :streetLine4, :maximum => 35, :allow_blank => true, message: I18n.t('errors.messages.maxlength35'), :if => lambda { |o| o.current_step == "contact"}
    elsif !streetLine4.nil? and streetLine4.length > 35
      Rails.logger.debug 'streetLine4 longer than allowed'
      errors.add(:streetLine4, I18n.t('errors.messages.maxlength35') )
    end
  end

  def validate_townCity
    #validates_presence_of :townCity, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
    if townCity.nil? or townCity == ""
      Rails.logger.debug 'townCity is empty'
      errors.add(:townCity, I18n.t('errors.messages.blank') )
    #validates :townCity, format: {with: VALID_CHARACTERS, message: I18n.t('errors.messages.invalid_characters') }, :if => lambda { |o| o.current_step == "contact"}
    elsif !townCity.nil? and townCity[VALID_CHARACTERS].nil?
      Rails.logger.debug 'townCity fails reg ex check'
      errors.add(:townCity, I18n.t('errors.messages.invalid_characters') )
    end
  end

  def validate_country
    if country.nil? or country == ""
      Rails.logger.debug 'country is empty'
      errors.add(:country, I18n.t('errors.messages.blank') )
    elsif !country.nil? and streetLine4[VALID_CHARACTERS].nil?
      Rails.logger.debug 'country fails reg ex check'
      errors.add(:country, I18n.t('errors.messages.invalid_characters') )
    #validates_length_of :country, :maximum => 35, :allow_blank => true, message: I18n.t('errors.messages.maxlength35'), :if => lambda { |o| o.current_step == "contact"}
    elsif !country.nil? and country.length > 35
      Rails.logger.debug 'country longer than allowed'
      errors.add(:country, I18n.t('errors.messages.maxlength35') )
    end
  end

  def validate_postcode
    #validates_presence_of :postcode, :if => lambda { |o| o.current_step == "contact" and o.uprn == ""}
    if postcode.nil? or postcode == ""
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
    #validates :contactEmail, :if => lambda { |o| o.current_step == "contact" && o.routeName == 'DIGITAL'}, format:{with:/\A[a-zA-Z0-9_.+\-']+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\Z/, message:I18n.t('errors.messages.invalidEmail') }
    elsif !contactEmail.nil? and !contactEmail.empty? and contactEmail[/\A[a-zA-Z0-9_.+\-']+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\Z/].nil?
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
    #validates :accountEmail, :if => lambda { |o| o.current_step == "signup" && o.sign_up_mode != "" }, format:{with:/\A[a-zA-Z0-9_.+\-']+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\Z/, message:I18n.t('errors.messages.invalidEmail') }
    elsif !accountEmail.nil? and accountEmail[/\A[a-zA-Z0-9_.+\-']+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\Z/].nil?
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
        # # Uncomment if we don't want to allow additional registrations
        # if @user && !user.confirmed?
        #   errors.add(:password, 'User account not confirmed')
        # end
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

  def validate_revokedReason
    #validate :validate_revokedReason, :if => lambda { |o| o.persisted? }
    Rails.logger.debug 'validate revokedReason, revoked:' + revoked.to_s
    # If revoke question is Yes, and revoke reason is empty, then error
    if revoked.to_s != ''
      if metaData.revokedReason == '' || metaData.revokedReason.nil?
        Rails.logger.debug 'revokedReason is empty'
        errors.add(:revokedReason, I18n.t('errors.messages.blank') )
      end
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
    (0...6).map { (65 + SecureRandom.random_number(26)).chr }.join
  end

  def assisted_digital?
    metaData.try(:route) == 'ASSISTED_DIGITAL'
  end

  def boxClassSuffix
    case metaData.status
      when 'REVOKED'
        'revoked'
      when 'PENDING'
        'pending'
      else
        ''
    end
  end

  def date_registered
    metaData.dateRegistered if metaData
  end

  #TODO Replace with method from helper or have decorator
  def formatted_registration_date
    if date_registered
      d = date_registered.to_date
      d.strftime('%A ' + d.mday.ordinalize + ' %B %Y')
    else
      ''
    end
  end

  def self.activate_registrations(user)
    Rails.logger.info("Activating pending registrations for user with email " + user.email)
    Registration.find(:all, :params => {:ac => user.email}).each { |r|
      if r.pending?
        Rails.logger.info("Activating registration " + r.regIdentifier)
        r.activate!
        r.save!
        RegistrationMailer.welcome_email(user,r).deliver
      else
        Rails.logger.info("Skipping non-pending registration " + r.regIdentifier)
      end
    }
    Rails.logger.info("Activated registration(s) for user with email " +  user.email)
  end

end
