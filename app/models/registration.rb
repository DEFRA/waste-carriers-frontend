
require 'active_model'

class Registration

  include ActiveModel::Validations
  include ActiveModel::Conversion
  #The services URL can be configured in config/application.rb and/or in the config/environments/*.rb files.
=begin
  self.site = Rails.configuration.waste_exemplar_services_url

  self.format = :json


=end

  SERVICES_URL = "#{Rails.configuration.waste_exemplar_services_url}/registrations.json"

  attr_writer :current_step

  attr_accessor  :businessType,
    :otherBusinesses,
    :isMainService,
    :constructionWaste,
    :onlyAMF,
    :companyName,
    :individualsType,
    :publicBodyType,
    :publicBodyTypeOthe,
    :registrationType,
    :houseNumber,
    :addressMode,
    :postcodeSearch,
    :selectedMoniker,
    :streetLine1,
    :streetLine2,
    :townCity,
    :postcode,
    :easting,
    :northing,
    :dependentLocality,
    :dependentThroughfa,
    :administrativeArea,
    :royalMailUpdateDate,
    :localAuthorityUpdate,
    :company_no,
    :expires_on,
    #payment
    :total_fee,
    :registration_fee,
    :copy_card_fee,
    :copy_cards,
    # Non UK fields
    :streetLine3,
    :streetLine4,
    :country,
    #
    :title,
    :otherTitle,
    :firstName,
    :lastName,
    :position,
    :phoneNumber,
    :contactEmail,
    :accountEmail,
    :declaration,
    :regIdentifier,
    :status,
    :password,
    :sign_up_mode,
    :routeName,
    :accessCode,
    :tier,
    :metaData,
    # Used as a trigger value to force validation of the revoke reason field
    # When this value contains any value, the revokeReason field is validated
    :revoked

=begin
    # TODO: Determine if this is needed?
    string :uprn
    string :address
=end



  def initialize(session_params)
    session_params.each do |k, v|
      self.send("#{k}=",v)
    end
    metaData = {}
  end

  def save!
    @title = 'Mr'
    Rails.logger.debug self.to_json

    response = RestClient.post  SERVICES_URL,  self.to_json, :content_type => :json, :accept => :json



    Rails.logger.debug "services responded: #{response.code}"
    Rails.logger.debug "services body: #{response.body}"
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

  # TODO this regexs need to be rethought if allowing foreign waste carriers.
  # My advice is to not check the format for free text fields but keep them only for those things where the form is
  # well-defined such as for UK postcodes

  VALID_CHARACTERS = /\A[A-Za-z0-9\s\'\.&!%]*\Z/
  GENERAL_WORD_REGEX = /\A[a-zA-Z\s\-\']+\z/

  DISTANCES = %w[any 10 50 100]
  VALID_HOUSE_NAME_OR_NUMBER_REGEX = /\A[a-zA-Z0-9\'\s-]+\z/
  POSTCODE_CHARACTERS = /\A[A-Za-z0-9\s]*\Z/
  YES_NO_ANSWER = %w(yes no)
  VALID_TELEPHONE_NUMBER_REGEX = /\A[0-9\-+()\s]+\z/
  VALID_COMPANY_NAME_REGEX = /\A[a-zA-Z0-9\s\.\-&\']+\z/
  VALID_COMPANIES_HOUSE_REGISTRATION_NUMBER_REGEX = /\A\d{1,8}|[a-zA-Z]{2}\d{6}\z/i

  validates :businessType, presence: true, inclusion: { in: BUSINESS_TYPES }, if: :businesstype_step?
  validates :otherBusinesses, presence: true, inclusion: { in: YES_NO_ANSWER }, if: :otherbusinesses_step?
  validates :isMainService, presence: true, inclusion: { in: YES_NO_ANSWER }, if: :serviceprovided_step?
  validates :constructionWaste, presence: true, inclusion: { in: YES_NO_ANSWER }, if: :constructiondemolition_step?
  validates :onlyAMF, presence: true, inclusion: { in: YES_NO_ANSWER }, if: :onlydealwith_step?

  validates :companyName, presence: true, format: { with: VALID_COMPANY_NAME_REGEX, message: I18n.t('errors.messages.alpha70') }, length: { maximum: 70 }, if: 'businessdetails_step? or upperbusinessdetails_step?'

  with_options if: :lower_or_upper_contact_details_step? do |registration|
    registration.validates :firstName, presence: true, format: { with: GENERAL_WORD_REGEX }, length: { maximum: 35 }
    registration.validates :lastName, presence: true, format: { with: GENERAL_WORD_REGEX }, length: { maximum: 35 }
    registration.validates :position, presence: true, format: { with: GENERAL_WORD_REGEX }
    registration.validates :phoneNumber, presence: true, format: { with: VALID_TELEPHONE_NUMBER_REGEX }, length: { maximum: 20 }
  end

  validates :contactEmail, presence: true, email: true, if: [:digital_route?, :lower_or_upper_contact_details_step?]

  with_options if: [:address_step?, :manual_uk_address?] do |registration|
    registration.validates :houseNumber, presence: true, format: { with: VALID_HOUSE_NAME_OR_NUMBER_REGEX, message: I18n.t('errors.messages.lettersSpacesNumbers35') }, length: { maximum: 35 }
    registration.validates :streetLine1, presence: true, length: { maximum: 35 }
    registration.validates :streetLine2, length: { maximum: 35 }
    registration.validates :townCity, presence: true, format: { with: GENERAL_WORD_REGEX }
    registration.validates :postcode, presence: true, uk_postcode: true
  end

  with_options if: [:address_step?, :manual_foreign_address?] do |registration|
    registration.validates :streetLine1, presence: true, length: { maximum: 35 }
    registration.validates :streetLine2, :streetLine3, :streetLine4, length: { maximum: 35 }
    registration.validates :country, presence: true, length: { maximum: 35 }
  end

  validates :tier, presence: true, inclusion: { in: %w(LOWER UPPER) }, if: :signup_step?

  validates :accountEmail, presence: true, email: true, if: [:signup_step?, :sign_up_mode_present?]

  with_options if: [:signup_step?,  :do_sign_up?] do |registration|
    registration.validates :accountEmail, confirmation: true
    registration.validate :user_cannot_exist_with_same_account_email
  end

  with_options if: [:signup_step?, :sign_up_mode_present?] do |registration|
    registration.validates :password, presence: true, length: { in: 8..128 }
    registration.validates_strength_of :password, with: :accountEmail
    registration.validates :password, confirmation: true
  end

  validates :declaration, format: {with:/\A1\z/,message:I18n.t('errors.messages.accepted') }, if: 'confirmation_step? or upper_summary_step?'

  validates :registrationType, presence: true, inclusion: { in: %w(carrier_dealer broker_dealer carrier_broker_dealer) }, if: :registrationtype_step?

  with_options if: [:upperbusinessdetails_step?, :limited_company?] do |registration|
    registration.validates :company_no, presence: true, format: { with: VALID_COMPANIES_HOUSE_REGISTRATION_NUMBER_REGEX }
    registration.validate :limited_company_must_be_active
  end

  validates :copy_cards, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: :payment_step?

  # TODO the following validations were problematic or possibly redundant

  # TODO: FIX this Test All routes!! IS this needed
  #validates_presence_of :routeName, :if => lambda { |o| o.current_step == "business" }


  # TODO not sure whether to keep this validation or not since the sign_up mode is not supplied by the user
  # validates :sign_up_mode, presence: true, if: [:signup_step?, , :account_email_present?]
  # validates :sign_up_mode, inclusion: { in: %w[sign_up sign_in] }, allow_blank: true, if: [:signup_step?, ]

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

  def address_step?
    businessdetails_step? or upperbusinessdetails_step?
  end

  def businessdetails_step?
    current_step.inquiry.businessdetails?
  end

  def upperbusinessdetails_step?
    current_step.inquiry.upper_business_details?
  end

  def lower_or_upper_contact_details_step?
    contactdetails_step? or uppercontactdetails_step?
  end

  def contactdetails_step?
    current_step.inquiry.contactdetails?
  end

  def uppercontactdetails_step?
    current_step.inquiry.upper_contact_details?
  end

  def signup_step?
    current_step.inquiry.signup?
  end

  def registrationtype_step?
    current_step.inquiry.registrationtype?
  end

  def payment_step?
    current_step.inquiry.payment?
  end

  def upper_summary_step?
    current_step.inquiry.upper_summary?
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

  def limited_company?
    businessType == 'limitedCompany'
  end

  def account_email_present?
    accountEmail.present?
  end

  def self.business_type_options_for_select
    (BUSINESS_TYPES.collect {|d| [I18n.t('business_types.'+d), d]})
  end

  def self.distance_options_for_select
    (DISTANCES.collect {|d| [I18n.t('distances.'+d), d]})
  end

  def initialize_sign_up_mode(userEmail, signedIn)
    if signedIn
      ''
    elsif User.where(email: userEmail).exists?
      'sign_in'
    else
      'sign_up'
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

  def last_step?
    noregistration?
  end

  def noregistration?
    current_step == 'noregistration'
  end

  def confirmation_step?
    current_step == 'confirmation'
  end

  def limited_company_must_be_active
    case CompaniesHouseCaller.new(company_no).status
    when :not_found
      errors.add(:company_no, I18n.t('registrations.upper_contact_details.companies_house_registration_number_not_found'))
    when :inactive
      errors.add(:company_no, I18n.t('registrations.upper_contact_details.companies_house_registration_number_inactive'))
    when :error_calling_service
      errors.add(:company_no, I18n.t('registrations.upper_contact_details.companies_house_service_error'))
    end
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
    Rails.logger.debug 'validate revokedReason, revoked:' + revoked
    # If revoke question is Yes, and revoke reason is empty, then error
    if revoked.present?
      if metaData.revokedReason.blank?
        Rails.logger.debug 'revokedReason is empty'
        errors.add(:revokedReason, I18n.t('errors.messages.blank') )
      end
    end
  end

  def user_cannot_exist_with_same_account_email
    errors.add(:accountEmail, I18n.t('errors.messages.emailTaken') ) if User.where(email: accountEmail).exists?
  end

  def do_sign_in?
    sign_up_mode == 'sign_in'
  end

  def do_sign_up?
    sign_up_mode == 'sign_up'
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
    metaData.try :dateRegistered
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
