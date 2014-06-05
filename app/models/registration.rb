require 'active_resource'

class Registration < ActiveResource::Base

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
    string :company_no

    integer :total_fee
    integer :registration_fee
    integer :copy_card_fee
    integer :copy_cards

    # Non UK fields
    string :streetLine3
    string :streetLine4
    string :country

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

    string :password
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
    string :company_house_no
    
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

  VALID_CHARACTERS = /\A[A-Za-z0-9\s\'\.&!%]*\Z/
  GENERAL_WORD_REGEX = /\A[a-zA-Z\s\-\']+\z/

  DISTANCES = %w[any 10 50 100]
  POSTCODE_CHARACTERS = /\A[A-Za-z0-9\s]*\Z/
  YES_NO_ANSWER = %w(yes no)
  VALID_EMAIL_REGEX = Devise.email_regexp

  validates :businessType, presence: true, inclusion: { in: BUSINESS_TYPES }, if: :businesstype_step?
  validates :otherBusinesses, presence: true, inclusion: { in: YES_NO_ANSWER }, if: :otherbusinesses_step?
  validates :isMainService, presence: true, inclusion: { in: YES_NO_ANSWER }, if: :serviceprovided_step?
  validates :constructionWaste, presence: true, inclusion: { in: YES_NO_ANSWER }, if: :constructiondemolition_step?
  validates :onlyAMF, presence: true, inclusion: { in: YES_NO_ANSWER }, if: :onlydealwith_step?

  validates :companyName, presence: true, format: { with: /\A[a-zA-Z0-9\s\.\-&\']+\z/, message: I18n.t('errors.messages.alpha70') }, length: { maximum: 70 }, if: :businessdetails_step?


  with_options if: :contactdetails_step? do |registration|
    registration.validates :firstName, presence: true, format: { with: GENERAL_WORD_REGEX}, length: { maximum: 35 }
    registration.validates :lastName, presence: true, format: { with: GENERAL_WORD_REGEX}, length: { maximum: 35 }
    registration.validates :position, presence: true, format: { with: GENERAL_WORD_REGEX}
    registration.validates :phoneNumber, presence: true, format: { with: /\A[0-9\-+()\s]+\z/ }, length: { maximum: 20 }
  end

  with_options if: [:businessdetails_step?, :manual_uk_address?] do |registration|
    registration.validates :houseNumber, presence: true, format: { with: /\A[a-zA-Z0-9\'\s-]+\z/, message: I18n.t('errors.messages.lettersSpacesNumbers35') }, length: { maximum: 35 }
    registration.validates :townCity, presence: true, format: { with: GENERAL_WORD_REGEX}
    registration.validates :postcode, presence: true, uk_postcode: true
  end

  validates :addressMode, allow_blank: true, inclusion: { in: %w(manual-uk manual-foreign) }, if: :businessdetails_step?

  with_options if: [:businessdetails_step?, :manual_foreign_address?] do |registration|
    registration.validates :streetLine3, :streetLine4, length: { maximum: 35 }
    registration.validates :country, presence: true, length: { maximum: 35 }
  end

  with_options if: [:businessdetails_step?, :address_mode_present?] do |registration|
    registration.validates :streetLine1, presence: true, length: { maximum: 35 }
    registration.validates :streetLine2, length: { maximum: 35 }
  end

  with_options if: [:businessdetails_step?, :address_mode_blank?] do |registration|
    registration.validates :postcodeSearch, presence: true, uk_postcode: true
    registration.validates :selectedMoniker, presence: true
  end

  validates :contactEmail, presence: true, format: { with: VALID_EMAIL_REGEX }, if: [:contactdetails_step?, :digital_route?]
  validates :accountEmail, presence: true, format: { with: VALID_EMAIL_REGEX }, if: [:signup_step?, :sign_up_mode_present?]

  with_options if: [:signup_step?, :unpersisted?, :do_sign_up?] do |registration|
    registration.validates :accountEmail, confirmation: true
    registration.validate :user_cannot_exist_with_same_account_email
  end

  with_options if: [:signup_step?, :unpersisted?, :sign_up_mode_present?] do |registration|
    registration.validates :password, presence: true, length: { in: 8..128 }
    registration.validates_strength_of :password, with: :accountEmail
    registration.validates :password, confirmation: true
  end

  validates :declaration, acceptance: true, if: :confirmation_step?

  # TODO: FIX this Test All routes!! IS this needed
  #validates_presence_of :routeName, :if => lambda { |o| o.current_step == "business" }

  # Validate Revoke Reason
  # validate :validate_revokedReason, :if => lambda { |o| o.persisted? }

  # TODO not sure whether to keep this validation or not
  # validates :sign_up_mode, presence: true, if: [:signup_step?, :unpersisted?, :account_email_present?]
  # validates :sign_up_mode, inclusion: { in: %w[sign_up sign_in] }, allow_blank: true, if: [:signup_step?, :unpersisted?]

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

  def sign_up_mode_present?
    sign_up_mode.present?
  end

  def digital_route?
    routeName == 'DIGITAL'
  end

  def manual_uk_address?
    addressMode == 'manual-uk'
  end

  def manual_foreign_address?
    addressMode == 'manual-foreign'
  end

  def address_mode_present?
    addressMode.present?
  end

  def address_mode_blank?
    addressMode.blank?
  end

  def account_email_present?
    accountEmail.present?
  end

  def unpersisted?
    not persisted?
  end

  def self.business_type_options_for_select
    (BUSINESS_TYPES.collect {|d| [I18n.t('business_types.'+d), d]})
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

  def user_cannot_exist_with_same_account_email
    errors.add(:accountEmail, I18n.t('errors.messages.emailTaken') ) if User.where(email: accountEmail).exists?
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
