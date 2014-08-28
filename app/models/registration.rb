class Registration < Ohm::Model

  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  FIRST_STEP = 'businesstype'

  module Status
    ACTIVE = 1
    PENDING = 2
    REVOKED = 4
    EXPIRED = 8
    INACTIVE = 16
  end

  attribute :current_step

  #uuid assigned by mongo. Found when registrations are retrieved from the Java Service API
  attribute :uuid

  attribute :businessType
  attribute :otherBusinesses
  attribute :isMainService
  attribute :constructionWaste
  attribute :onlyAMF
  attribute :companyName
  attribute :individualsType
  attribute :publicBodyType
  attribute :publicBodyTypeOther
  attribute :registrationType
  attribute :houseNumber

  attribute :addressMode
  attribute :postcodeSearch
  attribute :selectedMoniker
  attribute :streetLine1
  attribute :streetLine2
  attribute :townCity
  attribute :postcode
  attribute :easting
  attribute :northing
  attribute :dependentLocality
  attribute :dependentThroughfare
  attribute :administrativeArea
  attribute :royalMailUpdateDate
  attribute :localAuthorityUpdateDate
  attribute :company_no
  attribute :expires_on

  #payment
  attribute :total_fee
  attribute :registration_fee
  attribute :renewal_fee
  attribute :copy_card_fee
  attribute :copy_cards
  attribute :balance

  # Non UK address fields
  attribute :streetLine3
  attribute :streetLine4
  attribute :country

  attribute :title
  attribute :otherTitle
  attribute :firstName
  attribute :lastName
  attribute :position
  attribute :phoneNumber
  attribute :contactEmail
  attribute :accountEmail
  attribute :declaration
  attribute :regIdentifier
  attribute :status

  attribute :password
  attribute :sign_up_mode

  attribute :password
  attribute :sign_up_mode
  attribute :accessCode

  attribute :tier
  attribute :location

  # The value that the waste carrier sets to say whether they admit to having
  # relevant people with relevant convictions
  attribute :declaredConvictions
  # Whether a match was made by the convictions service
  attribute :convictions_check_indicates_suspect
  # Initially set if either of the other 2 are set, it is the flag that denotes
  # to an NCCC user that the registraton needs to be checked, and if happy the
  # one they will set to false
  attribute :criminally_suspect

  set :metaData, :Metadata #will always be size=1
  set :key_people, :KeyPerson # is a true set
  set :finance_details, :FinanceDetails #will always be size=1


  index :accountEmail
  index :companyName

  ############## ROUTENAME ##############
  # The following code should be seen as temporary until we better understand
  # how we can remove the routeName property (which this code is) and still
  # have the Rspecs passing. The RSpec tests work on the basis (it seems) of
  # initialising a Registration via Registration.new but then calling methods
  # that rely on the metaData and finance_details objects being populated. You
  # cannot populate them however as you need to have called save against the
  # registration first, and we cannot override the new method to allow us to do
  # this.

  @route_name

  def routeName=(name)

    @route_name = name

    begin
      metaData.first.update(:route => name)
    rescue Exception => e
      Rails.logger.debug e.message
    end

  end

  def routeName
    begin
      route = self.try(:metaData).try(:first).try(:route)
      @route_name = route unless route.nil?
    rescue Exception => e
      Rails.logger.debug e.message
    end

    @route_name
  end

  ################# END #################

  def empty?
    self.attributes.empty?
  end

  def add(a_hash)
    if a_hash
      a_hash.each do |prop_name, prop_value|
        self.send("#{prop_name}=",prop_value)
      end
    else
      Rails.logger.info 'no registration params found'
    end
  end


  def empty_set(a_set)
    done = false
    if a_set.kind_of? Ohm::BasicSet && a_set.size > 0
      a_set.each {|item| a_set.delete(item)}
      done = true
    end
    done
  end #method

  # as far as we're concerned a Registration will be persisted if it has a uuid, since the only way to
  # get a uuid is after a successful commit
  #
  # @param none
  # @return  [boolean] true if persisted
  def persisted?
    self.uuid
  end


  # POSTs registration to Java/Dropwizard service - creates new registration to DB
  #
  # @param none
  # @return  [String] the uuid assigned by MongoDB
  def commit
    url = "#{Rails.configuration.waste_exemplar_services_url}/registrations.json"
    Rails.logger.debug "Registration: about to POST: #{ to_json.to_s}"

    begin
      response = RestClient.post url,
        to_json,
        :content_type => :json,
        :accept => :json


      result = JSON.parse(response.body)



      # following fields are set by the java service, so we assign them from the response hash
      self.uuid = result['id']
      self.metaData.first.update(dateRegistered: result['metaData']['dateRegistered'])
      self.metaData.first.update(lastModified: result['metaData']['lastModified'])
      Rails.logger.debug "dateRegistered: #{result['metaData']['dateRegistered'].to_s}"
      self.regIdentifier = result['regIdentifier']

      unless self.tier == 'LOWER'
        #if self.finance_details.size > 0
        #  self.finance.details.first.orders.each do |ord|
        #    ord.commit  self.uuid
        #  end
        #  self.finance.details.first.payments.each do |p|
        #    p.save!  self.uuid
        #  end
        #else
        #  self.finance_details.add FinanceDetails.init(result['financeDetails'])
        #end
        self.finance_details.add FinanceDetails.init(result['financeDetails'])
      end

      save
      Rails.logger.debug "Commited to service: #{to_json.to_s}"
    rescue => e
      Rails.logger.debug "Error in Commit to service: #{ e.to_s} || #{attributes.to_s}"
    end
    uuid
  end

  # DELETEs registration to Java/Dropwizard service - deletes registration from DB
  #
  # @param none
  # @return  [Boolean] true if registration removed
  def delete!
    url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{uuid}.json"
    Rails.logger.debug "Registration: about to DELETE: #{ to_json.to_s}"
    deleted = true
    begin
      response = RestClient.delete url

      # result = JSON.parse(response.body)
      self.uuid = nil
      save

    rescue => e
      Rails.logger.error e.to_s
      deleted = false
    end
    deleted
  end

  # PUTs registration to Java/Dropwizard service - updates registration to DB
  #
  # @param none
  # @return  [Boolean] true if registration updated
  def save!
    url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{uuid}.json"
    Rails.logger.debug "Registration financeDetails to PUT: #{self.finance_details.first.to_s}"
    Rails.logger.debug "Registration: #{uuid} about to PUT: #{ to_json}"
    saved = true
    begin
      response = RestClient.put url,
        to_json,
        :content_type => :json

      save


    rescue => e
      Rails.logger.error e.to_s
      saved = false
    end
    saved
  end

  # return a JSON Java/DropWizard API compatible representation of the registration object
  #
  # @param none
  # @return  [String]  the registration object in JSON form
  def to_json
    result_hash = {}
    datetime_format = "%Y-%m-%dT%H:%M:%S%z"
    self.attributes.each do |k, v|
      if (k.to_s.eql? 'expires_on')
        Rails.logger.debug "#{k} -- #{k.class.to_s} "

        #convert date to millisecs from epoch so that  the Java service can understand it
        if v.is_a? String
          puts "-------------------------------------- #{v}"
          result_hash[k] = DateTime.parse(v).strftime('%Q')
        elsif v.is_a? DateTime
          result_hash[k] = v.strftime('%Q')
        elsif v.is_a? Time
          result_hash[k] = v.to_i * 1000
        else
          result_hash[k] = v
        end
      else
        result_hash[k] = v
      end
    end

    result_hash['metaData'] = metaData.first.attributes.to_hash if metaData.size == 1
    key_people = []

    if self.key_people &&  self.key_people.size > 0
      self.key_people.each do  |person|
         key_people << person.to_hash
      end
      result_hash['key_people'] = key_people
    end #if

    if self.finance_details.size == 1
      result_hash['financeDetails'] = self.finance_details.first.to_hash
    end

    Rails.logger.debug "saving #{result_hash.to_json.to_s}"
    result_hash.to_json
  end

  # Retrieves all registration objects from the Java Service
  #
  # @param none
  # @return  [Array]  list of all registrations in MongoDB
  class << self
    def find_all
      result = registrations = []
      url = "#{Rails.configuration.waste_exemplar_services_url}/registrations.json"
      begin
        response = RestClient.get url
        if response.code == 200
          result = JSON.parse(response.body) #result should be Array
          Rails.logger.info "find_all returned: #{ result.size.to_s} registrations"
          result.each do |r|
            registrations << Registration.init(r)
          end
        else
          Rails.logger.error "Registration.find_all failed with a #{response.code} response from server"
        end
      rescue => e
        Rails.logger.error e.to_s
      end
      registrations
    end
  end

  # Retrieves a specific registration object from the Java Service based on its email value
  #
  # @param email [String] the accountEmail to search for
  # @return [Array] list of registrations in MongoDB matching the specified email
  class << self
    def find_by_email(email)
      accountEmailParam = {ac: email}.to_query
      Rails.logger.debug 'update search param to be encoded: ' + accountEmailParam.to_s
      registrations = []
      url = "#{Rails.configuration.waste_exemplar_services_url}/registrations.json?#{accountEmailParam}"
      begin
        response = RestClient.get url
        if response.code == 200
          all_regs = JSON.parse(response.body) #all_regs should be Array
          Rails.logger.debug "find found #{all_regs.size.to_s} items"
          all_regs.each do |r|
            Rails.logger.debug "#{r['id']}"
            registrations << Registration.init(r)
          end
          Rails.logger.debug "#{registrations.size}"
        else
          Rails.logger.error "Registration.find_by_email(#{email}) failed with a #{response.code} response from server"
        end
      rescue => e
        Rails.logger.error e.to_s
      end
      registrations
    end
  end

  # Use instead of new or create. This properly instantiates the registration object
  # with the metaData and finance_details sets populated with their initial objects.
  class << self
    def ctor(attrs = {})

      r = Registration.create attrs

      m = Metadata.create
      m.update(:route => 'DIGITAL')
      r.metaData.add m

      f = FinanceDetails.create
      r.finance_details.add f

      r.save
    end
  end

  # Retrieves a specific registration object from the Java Service based on its email value
  #
  # @param some_text [String] the text to search for
  # @param within_field [String] within this specific field
  # @return [Array] list of registrations in MongoDB matching the specified email
  class << self
    def find_all_by(some_text, within_field)
      registrations = []
      url = "#{Rails.configuration.waste_exemplar_services_url}/registrations.json?q=#{some_text}&searchWithin=#{within_field}"
      begin
        response = RestClient.get url
        if response.code == 200
          all_regs = JSON.parse(response.body) #all_regs should be Array
          Rails.logger.debug "find_all_by found #{all_regs.size.to_s} items"
          all_regs.each do |r|
            registrations << Registration.init(r)
          end
        else
          Rails.logger.error "Registration.find_all_by(#{some_text}, #{within_field}) failed with a #{response.code} response from server"
        end
      rescue => e
        Rails.logger.error e.to_s
      end
      registrations
    end
  end

  # Retrieves a specific registration object from the Java Service based on its uuid
  #
  # @param registration_id [String] the Java Service response JSON object uuid
  # @return [Registration] the registration in MongoDB matching the uuid
  class << self
    def find_by_id(mongo_id)
      result = {}
      url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{mongo_id}.json"
      begin
        Rails.logger.debug "about to GET: #{mongo_id.to_s}"
        response = RestClient.get url
        if response.code == 200
          result = JSON.parse(response.body) #result should be Hash
        else
          Rails.logger.error "Registration.find_by_id failed with a #{response.code.to_s} response from server"
        end
      rescue => e
        Rails.logger.error e.to_s
      end
      Rails.logger.debug "found reg: #{result.to_s}"
      result.size > 0 ? Registration.init(result) : nil
    end
  end

  # Retrieves registration objects from the Java Service based on the values
  # included in the params hash
  #
  # @params a hash of params and their arguments to use in the find. Values can
  # be arrays
  # @options a hash of options you can pass through to the method. These allow
  # you to override the defaults it uses. They are :root_url (defaults to the
  # services url), :url (defaults to /registrations), and :format (defaults to
  # .json)
  # @return [Array] list of registrations in MongoDB matching the specified email
  class << self
    def find_by_params(params, options = {})

      defaults = {
        :root_url => "#{Rails.configuration.waste_exemplar_services_url}",
        :url => "/registrations",
        :format => ".json"
      }
      options = defaults.merge(options)

      registrations = []
      url = "#{options[:root_url]}#{options[:url]}#{options[:format]}?#{params.to_query}"
      # url = "#{Rails.configuration.waste_exemplar_services_url}/registrations.json?#{params.to_query}"
      Rails.logger.debug "find_by_params url=#{url}"
      begin
        response = RestClient.get url
        if response.code == 200
          all_regs = JSON.parse(response.body) #all_regs should be Array
          Rails.logger.debug "find_by_params found #{all_regs.size.to_s} items"
          all_regs.each do |r|
            registrations << Registration.init(r)
          end
        else
          Rails.logger.error "Registration.find_by_params() [#{url}] failed with a #{response.code} response from server"
        end
      rescue => e
        Rails.logger.error e.to_s
      end
      registrations
    end
  end

  # Creates a new Registration object from a JSON payload received from the Java Service
  #
  # @param response_hash [Hash] the Java Service response JSON object
  # @return [Registration] the Java Service object converted into a Registration object.
  class << self
    def init (response_hash)
      new_reg = Registration.create

      response_hash.each do |k, v|

        case k
        when 'id'
          new_reg.uuid = v
        when 'expiresOn', 'expires_on'
          new_reg.expires_on = convert_date(v)

        when 'address', 'uprn'
          #TODO: do nothing for now, but these API fields are redundant and should be removed
        when 'key_people'
          if v && v.size > 0
            Rails.logger.info "getting key people"
            v.each do |person|
              new_reg.key_people.add KeyPerson.init(person)
            end
             Rails.logger.info "key people size = #{new_reg.key_people.size.to_s}"
          end #if
        when 'metaData'
          new_reg.metaData.add HashToObject(v, 'Metadata')
        when 'financeDetails'
          #Rails.logger.debug '-----------------'
          #Rails.logger.debug 'Create finance details from v: ' + v.to_s
          #Rails.logger.debug '-----------------'
          new_reg.finance_details.add FinanceDetails.init(v)
        else  #normal attribute'
          new_reg.send(:update, {k.to_sym => v})
        end
      end #each
      new_reg.save
      #Rails.logger.debug '-----------------'
      #Rails.logger.debug 'Finance details from new_reg: ' + new_reg.finance_details.to_json.to_s
      #Rails.logger.debug '-----------------'
      new_reg
    end #method
  end

  class << self
    def HashToObject(hash, klass_name)
      klass = Object.const_get( klass_name )
      obj = klass.new
      hash.each do |k, v|
        obj.send("#{k.to_s}=",v)
      end
      obj.save
      obj
    end
  end

  def copy_construct
    Registration.init(self.to_json)
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
  VALID_HOUSE_NAME_OR_NUMBER_REGEX = /\A[a-zA-Z0-9\'\s\,-]+\z/
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
  validates :declaredConvictions, presence: true, inclusion: { in: YES_NO_ANSWER }, if: :convictions_step?

  validates :companyName, presence: true, format: { with: VALID_COMPANY_NAME_REGEX, message: I18n.t('errors.messages.alpha70') }, length: { maximum: 70 }, if: 'businessdetails_step?'

  with_options if: :contactdetails_step? do |registration|
    registration.validates :firstName, presence: true, format: { with: GENERAL_WORD_REGEX }, length: { maximum: 35 }
    registration.validates :lastName, presence: true, format: { with: GENERAL_WORD_REGEX }, length: { maximum: 35 }
    registration.validates :position, format: { with: GENERAL_WORD_REGEX }, :allow_nil => true, :allow_blank => true
    registration.validates :phoneNumber, presence: true, format: { with: VALID_TELEPHONE_NUMBER_REGEX }, length: { maximum: 20 }
  end

  validates :contactEmail, presence: true, email: true, if: [:digital_route?, :contactdetails_step?]

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

  validates! :tier, presence: true, inclusion: { in: %w(LOWER UPPER) }, if: :signup_step?
  validate :validate_key_people, if: :key_person_step?

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

  validate :is_valid_account?, if: [:signin_step?, :sign_up_mode_present?]

  validates :declaration, acceptance: true, if: 'confirmation_step? or upper_summary_step?'

  validates :registrationType, presence: true, inclusion: { in: %w(carrier_dealer broker_dealer carrier_broker_dealer) }, if: :registrationtype_step?

  with_options if: [:businessdetails_step?, :limited_company?] do |registration|
    registration.validates :company_no, presence: true, format: { with: VALID_COMPANIES_HOUSE_REGISTRATION_NUMBER_REGEX }
    registration.validate :limited_company_must_be_active
  end

  validates :copy_cards, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: :payment_step?

  # TODO the following validations were problematic or possibly redundant

  # Validate Revoke Reason
  # validate :validate_revokedReason, :if => lambda { |o| o.persisted? }

  # TODO not sure whether to keep this validation or not since the sign_up mode is not supplied by the user
  # validates :sign_up_mode, presence: true, if: [:signup_step?, , :account_email_present?]
  # validates :sign_up_mode, inclusion: { in: %w[sign_up sign_in] }, allow_blank: true, if: [:signup_step?, ]

  def is_valid_account?
    user = User.find_by_email(accountEmail)
    if user.nil? || !user.valid_password?(password)
      errors.add(:password, I18n.t('errors.messages.invalidPassword'))
    else
      unless user.confirmed?
        errors.add(:accountEmail, I18n.t('errors.messages.unconfirmedEmail'))
      end
    end
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

  def address_step?
    businessdetails_step?
  end

  def businessdetails_step?
    current_step.inquiry.businessdetails?
  end

  def contactdetails_step?
    current_step.inquiry.contactdetails?
  end

  def key_person_step?
    current_step.inquiry.key_person?
  end

  def signup_step?
    current_step.inquiry.signup?
  end

  def signin_step?
    current_step.inquiry.signin?
  end

  def registrationtype_step?
    current_step.inquiry.registrationtype?
  end

  def payment_step?
    current_step.inquiry.payment?
  end

  def convictions_step?
    current_step.inquiry.convictions?
  end

  def upper_summary_step?
    current_step.inquiry.upper_summary?
  end

  def sign_up_mode_present?
    sign_up_mode.present?
  end

  def do_sign_in?
    sign_up_mode == 'sign_in'
  end

  def do_sign_up?
    sign_up_mode == 'sign_up'
  end

  def digital_route?
    begin
      route = self.try(:metaData).try(:first).try(:route)
    rescue Exception => e
      Rails.logger.debug e.message
    end

    route == 'DIGITAL'
  end

  def assisted_digital?
    begin
      route = self.try(:metaData).try(:first).try(:route)
    rescue Exception => e
      Rails.logger.debug e.message
    end

    route == 'ASSISTED_DIGITAL'
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

  def upper?
    return false if tier.blank?
    tier.inquiry.UPPER?
  end

  def lower?
    return true if tier.blank?
    tier.inquiry.LOWER?
  end

  def paid_in_full?
    begin
      the_balance = self.try(:finance_details).try(:first).try(:balance)

      the_balance = 0 if the_balance.nil?
    rescue Exception => e
      Rails.logger.debug e.message
    end

    the_balance.to_i <= 0
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

  def last_step?
    current_step == 'noregistration'
  end

  def confirmation_step?
    current_step == 'confirmation'
  end

  def limited_company_must_be_active
    case CompaniesHouseCaller.new(company_no).status
    when :not_found
      errors.add(:company_no, I18n.t('registrations.company_details_finder.companies_house_registration_number_not_found'))
    when :inactive
      errors.add(:company_no, I18n.t('registrations.company_details_finder.companies_house_registration_number_inactive'))
    when :error_calling_service
      errors.add(:company_no, I18n.t('registrations.company_details_finder.companies_house_service_error'))
    end
  end

  def pending?
    metaData && metaData.first.status == 'PENDING'
  end

  def pending!
    metaData.first.update(status: 'PENDING')
    save!
  end

  def activate!
    #Note: the actual status update will be performed in the service
    Rails.logger.debug "id to activate: #{uuid}"
    metaData.first.update(status: 'ACTIVE')
    save!
  end

  def validate_revokedReason
    #validate :validate_revokedReason, :if => lambda { |o| o.persisted? }
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

  def user
    @user || User.find_by_email(accountEmail) || AgencyUser.find_by_email(accountEmail)
  end

  def generate_random_access_code
    (0...6).map { (65 + SecureRandom.random_number(26)).chr }.join
  end

  def boxClassSuffix
    case metaData.first.status
    when 'REVOKED'
      'revoked'
    when 'PENDING'
      'pending'
    else
      ''
    end
  end

  def date_registered
    metaData.first.dateRegistered
  end

  def getOrder( orderCode)
    Rails.logger.info 'Registration getOrder ' + orderCode.to_s
    foundOrder = nil
    self.finance_details.first.orders.each do |order|
      Rails.logger.info 'Order ' + order.orderCode.to_s
      if orderCode.to_i == order.orderCode.to_i
        Rails.logger.info 'Registration Found order ' + orderCode.to_s
        foundOrder = order
      end
    end
    foundOrder
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

  # Call to determine whether the registration is 'complete' i.e. there are no
  # outstanding checks, payment has been made and the account has been activated
  def is_complete?
    is_complete = true

    Rails.logger.debug "is_complete: In method"
    unless metaData.first.status == 'ACTIVE'
      Rails.logger.debug "is_complete: status = #{metaData.first.status}"
      is_complete = false
      return
    end

    if criminally_suspect
      Rails.logger.debug "is_complete: suspect = #{criminally_suspect}"
      is_complete = false
      return
    end

    unless paid_in_full?
      Rails.logger.debug "is_complete: paid_in_full = #{paid_in_full?}"
      is_complete = false
      return
    end

    is_complete

  end

  def self.activate_registrations(user)
    Rails.logger.info "Activating pending registrations for user with email #{user.email}"
    rs = Registration.find_by_email(user.email)
    Rails.logger.info("found: #{rs.size} pending registrations")
    rs.each do |r|
      if r.pending? and Registration.isReadyToBeActive(r)
        Rails.logger.debug "debug: #{r.attributes.to_s}"
        Rails.logger.info "Activating registration #{r.regIdentifier}"
        r.activate!
        Rails.logger.debug "registration #{r.id} activated!"
        
        #
        # NOTE:
        # Should be able to use the following but there is a bug that currently mean agency users are creating DIGITAL routes
        # Rails.logger.debug 'route: ' + r.metaData.first.route.to_s
        # if r.metaData.first.route == 'DIGITAL'
        #
        # FIXME: Replace the 'is_agency_user?', with 'r.metaData.first.route ...' once the above defect is resolved
        #
        if !user.is_agency_user?
          Rails.logger.debug "Send registration email"
          RegistrationMailer.welcome_email(user,r).deliver
        else 
          Rails.logger.debug "Registration not Digital, thus registraion email not to be sent"
        end
      else
        Rails.logger.info "Skipping non-pending registration #{r.regIdentifier}"
      end
    end #each
    Rails.logger.info "Activated registration(s) for user with email #{user.email}"
  end
  
  def self.isReadyToBeActive(reg)
    reg.paid_in_full? and !reg.criminally_suspect
  end

  # Converts a date from either a String or Java(ms) format to a String time, properly formatted
  #
  # @param d [String, Numeric] the date to convert
  # @return [String]
  class << self
    def convert_date d

      res =Time.new(1970,1,1)
      if d
        begin
          res =  Time.at(d / 1000.0)
          # if d is String the NoMethodError will be raised
        rescue NoMethodError
          res =  Time.parse(d)
        end
      end #if
      res
    end
  end

  # FIXME why is this validation necessary?
  def validate_key_people
    if key_people.blank?
      errors.add('Key people', 'is invalid.') unless set_dob
    end
  end

end
