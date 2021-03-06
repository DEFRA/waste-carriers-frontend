class Registration < Ohm::Model

  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming
  include PasswordHelper
  include ApplicationHelper
  include CanBeRenewed

  FIRST_STEP = 'newOrRenew'

  module Status
    ACTIVE = 1
    PENDING = 2
    REVOKED = 4
    EXPIRED = 8
    INACTIVE = 16
  end

  attribute :current_step

  # uuid assigned by mongo. Found when registrations are retrieved from the Java Service API
  # Note: this is the id (_id) assigned by the database.
  attribute :uuid

  # We are generating a uuid client-side (in the frontend) in order to make the POST idempotent
  # and to guard against accidentally repeated requests.
  # This is used in the regitstration step pages URL's
  attribute :reg_uuid
  index :reg_uuid
  unique :reg_uuid

  # New or renew field used to determine initial routing prior to smart answers
  attribute :newOrRenew
  attribute :originalRegistrationNumber
  attribute :originalDateExpiry

  attribute :location
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

  attribute :postcodeSearch # unknown address attribute
  attribute :selectedMoniker # unknown address attribute

  attribute :company_no
  attribute :expires_on

  #payment
  attribute :total_fee
  attribute :registration_fee
  attribute :copy_card_fee
  attribute :copy_cards
  attribute :balance
  attribute :payment_type

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
  attribute :accessCode

  attribute :tier

  attribute :renewalRequested

  # This binds to the address select control on the business details page when
  # used in its lookup mode, When posted the controller grabs the selected value
  # and uses it to populate the registered address
  attribute :selectedAddress

  # The value that the waste carrier sets to say whether they admit to having
  # relevant people with relevant convictions
  attribute :declaredConvictions

  # These are meta data fields used only in rails for storing a temporary value to determine:
  # the exception detail from the services
  # whether the relevant order is only for copy cards
  # whether the controller/view is at the address lookup page
  attribute :exception
  attribute :copy_card_only_order

  set :addresses, :Address
  set :metaData, :Metadata #will always be size=1
  set :key_people, :KeyPerson # is a true set
  set :finance_details, :FinanceDetails #will always be size=1

  set :conviction_search_result, :ConvictionSearchResult #will always be size=1
  set :conviction_sign_offs, :ConvictionSignOff #can be empty

  index :accountEmail
  index :companyName

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
      Rails.logger.debug 'no registration params found'
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

  def save
    self.reg_uuid = SecureRandom.urlsafe_base64 unless reg_uuid.present?
    super
  end

  # POSTs registration to Java/Dropwizard service - creates new registration to DB
  # @return  [String] the uuid assigned by MongoDB
  def commit
    commited = false

    finance_detail = self.finance_details.first || FinanceDetails.create
    finance_detail.orders << order_builder.order if finance_detail.orders.empty?
    self.finance_details.replace([finance_detail])

    begin
      url = "#{Rails.configuration.waste_exemplar_services_url}/registrations.json"
      response = RestClient.post(url, to_json, :content_type => :json, :accept => :json)

      result = JSON.parse(response.body)

      # Update this object by replacing certain values that are determined by
      # the Java services layer.  We don't need to call update or save here, as
      # we already call save() later in this method.
      self.uuid = result['id']
      self.regIdentifier = result['regIdentifier']
      self.expires_on = result['expires_on'] if result.has_key?('expires_on')

      if result['addresses'] #array of addresses
        address_list = []
        result['addresses'].each do |address_hash|
          address = Address.init(address_hash)
          address_list << address
        end
        self.addresses.replace(address_list)
      end

      self.metaData.replace([Metadata.init(result['metaData'])])

      if result['conviction_search_result']
        self.conviction_search_result.replace([ConvictionSearchResult.init(result['conviction_search_result'])])
      end

      if result['conviction_sign_offs'] #array of conviction sign offs
        sign_offs = []
        result['conviction_sign_offs'].each do |sign_off_hash|
          sign_off = ConvictionSignOff.init(sign_off_hash)
          sign_offs << sign_off
        end
        self.conviction_sign_offs.replace(sign_offs)
      end

      unless self.tier == 'LOWER'
        Rails.logger.debug 'Initialise finance details'
        self.finance_details.replace([FinanceDetails.init(result['financeDetails'])])
      end

      save
      commited = true
    rescue Errno::ECONNREFUSED => e
      Airbrake.notify(e)
      Rails.logger.error 'Services unavailable: ' + e.to_s
      self.exception = e.to_s
    rescue => e
      Airbrake.notify(e)
      Rails.logger.debug "Error in registration Commit to service: #{e.to_s}"
      self.exception = e.to_s
    end
    commited
  end

  # DELETEs registration to Java/Dropwizard service - deletes registration from DB
  #
  # @param none
  # @return  [Boolean] true if registration removed
  def delete!
    url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{uuid}.json"
    Rails.logger.debug "Registration: about to DELETE"
    deleted = true
    begin
      response = RestClient.delete url

      # result = JSON.parse(response.body)
      self.uuid = nil
      save

    rescue => e
      Airbrake.notify(e)
      Rails.logger.error e.to_s
      deleted = false
    end
    deleted
  end

  # PUTs registration to Java/Dropwizard service - updates registration to DB
  # @return  [Boolean] true if registration updated
  def save!
    url = "#{Rails.configuration.waste_exemplar_services_url}/registrations/#{uuid}.json"
    saved = true
    begin
      response = RestClient.put(url, to_json, content_type: :json, accept: :json)
      result = JSON.parse(response.body)

      # Update metadata and financedetails with that from the service
      if result['addresses'] #array of addresses
        address_list = []
        result['addresses'].each do |address_hash|
          address = Address.init(address_hash)
          address_list << address
        end
        self.addresses.replace(address_list)
      end

      self.metaData.replace( [Metadata.init(result['metaData'])])


      unless self.tier == 'LOWER'
        Rails.logger.debug 'Initialise finance details'
        self.finance_details.replace( [FinanceDetails.init(result['financeDetails'])] )
      end

      self.conviction_search_result.replace( [ConvictionSearchResult.init(result['conviction_search_result'])]) if result['conviction_search_result']

      if result['conviction_sign_offs'] #array of conviction sign offs
        sign_offs = []
        result['conviction_sign_offs'].each do |sign_off_hash|
          sign_off = ConvictionSignOff.init(sign_off_hash)
          sign_offs << sign_off
        end
        self.conviction_sign_offs.replace sign_offs
      end

      save
    rescue => e
      Airbrake.notify(e)
      Rails.logger.error 'An error occurred during saving the registration: ' + e.to_s

      if e.try(:http_code)
        if e.http_code == 422
          # Get actual error from services
          htmlDoc = Nokogiri::HTML(e.http_body)
          messageFromServices = htmlDoc.at_css("body ul li").content
          Rails.logger.error messageFromServices
          # Update order with a exception message
          self.exception = messageFromServices
        elsif e.http_code == 400
          # Get actual error from services
          htmlDoc = Nokogiri::HTML(e.http_body)
          messageFromServices = htmlDoc.at_css("body pre").content
          Rails.logger.error messageFromServices
          # Update order with a exception message
          self.exception = messageFromServices
        end
      else
        self.exception = e.to_s
      end

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
    self.attributes.each do |k, v|
      result_hash[k] = v
    end

    address_list = []
    if addresses && addresses.size > 0
      addresses.each do |address|
        address_list << address.to_hash
      end
      result_hash['addresses'] = address_list
    end # if

    result_hash['metaData'] = metaData.first.attributes.to_hash if metaData.size == 1

    key_people_list = []
    if key_people && key_people.size > 0
      key_people.each do  |person|
        key_people_list << person.to_hash
      end
      result_hash['key_people'] = key_people_list
    end #if

    result_hash['financeDetails'] = finance_details.first.to_hash if finance_details.size == 1

    result_hash['conviction_search_result'] = conviction_search_result.first.to_hash if conviction_search_result.size == 1

    sign_offs = []
    if conviction_sign_offs && conviction_sign_offs.size > 0
      conviction_sign_offs.each do  |sign_off|
        sign_offs << sign_off.to_hash
      end
      result_hash['conviction_sign_offs'] = sign_offs
    end #if

    result_hash.to_json
  end

  def cross_check_convictions
    if company_no.blank? || foreign_limited_company?
      result = ConvictionSearchResult.search_company_convictions(
        name: companyName,
      )
    else
      result = ConvictionSearchResult.search_company_convictions(
        name: companyName,
        number: company_no
      )
    end

    conviction_search_result.replace([result])
  end

  # Returns a boolean indicating if the user declared convictions.
  def has_declared_convictions?
    declaredConvictions != 'no'
  end

  # Returns a boolean indicating if a possible match was found when searching
  # for convictions against the company.
  def company_convictions_match_found?
    conviction_search_result.first &&
      (conviction_search_result.first.match_result != 'NO')
  end

  # Returns a boolean indicating if a possible match was found when searching
  # for convictions against the key people.
  def people_convictions_match_found?
    if key_people
      key_people.each do |person|
        search_result = person.conviction_search_result.first
        if search_result && search_result.match_result != 'NO'
          return true;
        end
      end
    end
    false
  end

  # Returns a boolean indicating if a possible match was found when searching
  # for convictions, for the company AND for the key people.
  def company_and_people_convictions_match_found?
    company_convictions_match_found? && people_convictions_match_found?
  end

  def has_unconfirmed_convictionMatches?

    result = false

    search_result = conviction_search_result.first
    if search_result
      if search_result.match_result != 'NO' && search_result.confirmed == 'no'
        result = true
      end
    else
      if key_people
        key_people.each do |person|
          search_result = person.conviction_search_result.first
          if search_result
            if search_result.match_result != 'NO' && search_result.confirmed == 'no'
              result = true
              break
            end
          end
        end
      end
    end

    result

  end

  def is_awaiting_conviction_confirmation?(agency_user=nil)

    result = false

    unless tier.eql? 'LOWER'
      if conviction_sign_offs
        conviction_sign_offs.each do |sign_off|
          if sign_off.confirmed == 'no'
            result = user_can_edit_registration(agency_user)
            break
          end
        end
      end
    end

    result

  end

  # Retrieves a specific registration object from the Java Service based on its email value
  #
  # @param email [String] the accountEmail to search for
  # @return [Array] list of registrations in MongoDB matching the specified email
  class << self
    def find_by_email(email, with_statuses=nil)
      accountEmailParam = CGI.escape(email)
      registrations = []
      url = "#{Rails.configuration.waste_exemplar_services_url}/search/account?email=#{accountEmailParam}"
      begin
        response = RestClient.get url
        if response.code == 200
          all_regs = JSON.parse(response.body) #all_regs should be Array
          Rails.logger.debug "find_by_email found #{all_regs.size.to_s} items"
          all_regs.each do |r|
            Rails.logger.debug "#{r['id']}"
            registrations << Registration.init(r)
          end
          Rails.logger.debug "#{registrations.size}"
        else
          Rails.logger.error "Registration.find_by_email(#{email}) failed with a #{response.code} response from server"
        end
      rescue => e
        Airbrake.notify(e)
        Rails.logger.error e.to_s
      end

      #filter on desired statuses, if status array argument has been passed
      registrations =  registrations.select{|r| with_statuses.include? r.get_status } if with_statuses

      registrations
    end
  end

  # Use instead of new or create. This properly instantiates the registration object
  # with the metaData and finance_details sets populated with their initial objects.
  class << self
    def ctor(attrs = {})
      agency_user_signed_in = false
      if (attrs != nil) && attrs.key?(:agency_user_signed_in)
        agency_user_signed_in = attrs[:agency_user_signed_in]
        attrs.delete(:agency_user_signed_in)
      end

      r = Registration.create attrs

      m = Metadata.create
      if agency_user_signed_in
        m.update(:route => 'ASSISTED_DIGITAL')
      else
        m.update(:route => 'DIGITAL')
      end
      r.metaData.add m

      r.addresses.add(Address.init(addressType: 'REGISTERED'))
      r.addresses.add(Address.init(addressType: 'POSTAL'))

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
      all_regs = {}
      searchFor = CGI.escape(some_text)
      Rails.logger.debug "THE VALUE IS #{searchFor}"
      url = "#{Rails.configuration.waste_exemplar_services_url}/search/registrations/#{within_field}?value=#{searchFor}"
      Rails.logger.debug "THE URL IS #{url}"
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
        Airbrake.notify(e)
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
      rescue Errno::ECONNREFUSED => e
        Airbrake.notify(e)
        Rails.logger.error "Services unavailable: " + e.to_s
      rescue => e
        Airbrake.notify(e)
        Rails.logger.error e.to_s
      end
      result.size > 0 ? Registration.init(result) : nil
    end
  end

  # Retrieves a specific registration object from the Java Service based on its
  # registration number
  #
  # @param registration_no [String] the registration number
  # @return [Registration] the registration in MongoDB matching the registration number
  class << self
    def find_by_registration_no(registration_no)
      result = {}
      url = "#{Rails.configuration.waste_exemplar_services_url}/registrations.json/#{registration_no}"
      begin
        Rails.logger.debug "about to GET: #{registration_no.to_s}"
        response = RestClient.get url
        if response.code == 200
          result = JSON.parse(response.body) #result should be Hash
        else
          Rails.logger.error "Registration.find_by_registration_no failed with a #{response.code.to_s} response from server"
        end
      rescue Errno::ECONNREFUSED => e
        Airbrake.notify(e)
        Rails.logger.error "Services unavailable: " + e.to_s
      rescue => e
        Airbrake.notify(e)
        Rails.logger.error e.to_s
      end
      result.size > 0 ? Registration.init(result) : nil
    end
  end

  # Retrieves a specific registration object from the Java Service based on its
  # original registration number.
  #
  # @param registration_no [String] the original IR registration number
  # @return [Registration] the registration in MongoDB with an originalRegistrationNumber property that matches the registration number
  class << self
    def find_by_original_registration_no(registration_no)
      result = {}
      searchFor = CGI.escape(registration_no)
      url = "#{Rails.configuration.waste_exemplar_services_url}/search/original/#{searchFor}"
      begin
        Rails.logger.debug "about to GET: original registration no #{registration_no.to_s}"
        response = RestClient.get url
        if response.code == 200
          result = JSON.parse(response.body) #result should be Hash
        else
          Rails.logger.error "Registration.find_by_original_registration_no(#{registration_no}) failed with a #{response.code.to_s} response from server"
        end
      rescue Errno::ECONNREFUSED => e
        Airbrake.notify(e)
        Rails.logger.error "Services unavailable: " + e.to_s
      rescue => e
        Airbrake.notify(e)
        Rails.logger.error e.to_s
      end
      result.size > 0 ? Registration.init(result) : nil
    end
  end

  # Queries the Java services for an IR registration record with the specified
  # registration number. If found the Java services converts the IR record to a
  # Registration and return that.
  #
  # @param ir_number [String] the original registration number used in the legacy system
  # @return [Registration] the registration in IR data matching the ir_number
  class << self
    def find_by_ir_number(ir_number)
      irRenewalParam = {irNumber: ir_number}.to_query
      result = {}
      url = "#{Rails.configuration.waste_exemplar_services_url}/irrenewals.json?#{irRenewalParam}"
      begin
        Rails.logger.debug "about to GET ir registration: #{ir_number.to_s}"
        response = RestClient.get(url)
        if response.code == 200
          result = JSON.parse(response.body) #result should be Hash
        elsif response.code == 204
          # This is what is returned by the services if the IR Registration number
          # is not found.  This is an "expected" error-case, and definitely does
          # not require Airbrake logging.
          Rails.logger.debug "Services reports that IR Renewal number not found"
          result = {}
        else
          Rails.logger.error "Registration.find_by_ir_number failed with a #{response.code.to_s} response from server"
        end
      rescue Errno::ECONNREFUSED, Errno::ECONNRESET => e
        Airbrake.notify(e)
        Rails.logger.error "Services unavailable: " + e.to_s
      rescue => e
        Airbrake.notify(e)
        Rails.logger.error e.to_s
      end
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
      registrations = []
      begin
        defaults = {
            :root_url => "#{Rails.configuration.waste_exemplar_services_url}",
            :url => "/registrations",
            :format => ".json"
        }
        options = defaults.merge(options)

        url = "#{options[:root_url]}#{options[:url]}#{options[:format]}?#{params.to_query}"
        Rails.logger.debug "HERE ---> #{url}"
        response = RestClient.get(url)

        if response.code == 200
          all_regs = JSON.parse(response.body) #all_regs should be Array
          Rails.logger.warn 'Starting mapping of returned json to Registrations'
          all_regs.each do |r|
            registrations << Registration.init(r)
          end
          Rails.logger.warn 'Finished Mapping.'
        else
          Rails.logger.error {"Registration.find_by_params() [#{url}] failed with a #{response.code} response from server"}
        end
      rescue => e
        Airbrake.notify(e)
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
    def init(response_hash)
      reg_uuid = response_hash['reg_uuid']

      # Find and delete Redis registration for the reg_uuid
      existing_redis_reg = Registration.find(reg_uuid: reg_uuid).first

      new_reg = Registration.create

      normal_attributes = Hash.new

      response_hash.each do |k, v|
        case k
          when 'id'
            new_reg.uuid = v
          when 'reg_uuid'
            if existing_redis_reg.present?
              new_reg.reg_uuid = SecureRandom.urlsafe_base64
            else
              new_reg.reg_uuid = reg_uuid
            end
          when 'addresses'
            if v && v.any?
              v.each do |address|
                new_reg.addresses.add(Address.init(address))
              end
            end
          when 'key_people'
            if v && v.any?
              v.each do |person|
                new_reg.key_people.add(KeyPerson.init(person))
              end
            end #if
          when 'metaData'
            new_reg.metaData.add Metadata.init(v)
          when 'financeDetails'
            new_reg.finance_details.add FinanceDetails.init(v)
          when 'conviction_search_result'
            new_reg.conviction_search_result.add ConvictionSearchResult.init(v)
          when 'conviction_sign_offs'
            if v
              v.each do |sign_off|
                new_reg.conviction_sign_offs.add ConvictionSignOff.init(sign_off)
              end
            end
          else # normal attribute
            normal_attributes.store(k, v)
        end
      end #each

      new_reg.update_attributes(normal_attributes)
      new_reg.save

      new_reg
    end #method
  end

  def copy_construct
    Registration.init(self.to_json)
  end

  # Creates and returns a new registration, initialising most fields from an
  # existing instance.  This is intended to be used only in the case where the
  # user makes an edit requiring a new registration.  Specifically, finance
  # details and conviction sign-off results are not copied, and convictions
  # checks are re-run.
  def self.create_new_when_edit_requires_new_reg(original_registration)
    # Create a new registration, and initialise from the old.
    new_reg = Registration.create
    new_reg.add(original_registration.to_hash)
    new_reg.add(original_registration.attributes)
    new_reg.reg_uuid = SecureRandom.urlsafe_base64

    # New registration should not get the Finance Details or Conviction
    # sign-offs of the old.
    unless original_registration.finance_details.empty?
      new_reg.finance_details.replace([])
    end
    unless original_registration.conviction_sign_offs.empty?
      new_reg.conviction_sign_offs.replace([])
    end

    # New registration should trigger new conviction searches.
    if new_reg.upper?
        new_reg.key_people.each { |person| person.cross_check_convictions }
      new_reg.cross_check_convictions
    end

    # Return the result.
    new_reg
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

  REGISTRATION_TYPES = %w[
    renew
    new
  ]

  LOCATIONS = %w[
    england
    wales
    scotland
    northern_ireland
    overseas
  ]

  # TODO this regexs need to be rethought if allowing foreign waste carriers.
  # My advice is to not check the format for free text fields but keep them only for those things where the form is
  # well-defined such as for UK postcodes

  VALID_CHARACTERS = /\A[A-Za-z0-9\s\'\.&!%]*\Z/

  # TODO AH - ditch this one when individual ones created
  GENERAL_WORD_REGEX = /\A[a-zA-Z\s\-\']+\z/

  FIRST_NAME_REGEX = /\A[a-zA-Z\s\-\']+\z/
  LAST_NAME_REGEX = /\A[a-zA-Z\s\-\']+\z/
  POSITION_NAME_REGEX = /\A[a-zA-Z\s\-\']+\z/

  DISTANCES = %w[any 10 50 100]

  YES_NO_ANSWER = %w(yes no)
  VALID_TELEPHONE_NUMBER_REGEX = /\A[0-9\-+()\s]+\z/
  VALID_COMPANY_NAME_REGEX = /\A[a-zA-Z0-9\s\.\-&\'\u2019\[\]\,\(\)]+\z/

  # Maximum field lengths
  MAX_COMPANY_REGISTRATION_NO = 8
  MAX_FOREIGN_COMPANY_NUMBER_LENGTH = 50
  MAX_COMPANY_NAME_LENGTH = 150

  # *********************************
  # * Section 0 (start) validations *
  # *********************************
  validates :newOrRenew, :presence => { :message => I18n.t('errors.messages.select_new_or_renew') }, if: :newOrRenew_step?
  validates :originalRegistrationNumber, :presence => { :message => I18n.t('errors.messages.blank_registration_number') }, if: :enterRegNumber_step?
  validates :reg_uuid, presence: true # There must always be a reg_uuid

  # *****************************************
  # * Section 1 (smart answers) validations *
  # *****************************************
  validates :location, :presence => { :message => I18n.t('errors.messages.select_location') }, inclusion: { in: LOCATIONS, :allow_blank => true }, if: :location_step?
  validates :businessType, :presence => { :message => I18n.t('errors.messages.select_business_type') }, inclusion: { in: BUSINESS_TYPES, :allow_blank => true }, if: :businesstype_step?
  validates :otherBusinesses, :presence => { :message => I18n.t('errors.messages.select_other_businesses') }, inclusion: { in: YES_NO_ANSWER, :allow_blank => true }, if: :otherbusinesses_step?
  validates :isMainService, :presence => { :message => I18n.t('errors.messages.select_service_provided') }, inclusion: { in: YES_NO_ANSWER, :allow_blank => true }, if: :serviceprovided_step?
  validates :constructionWaste, :presence => { :message => I18n.t('errors.messages.select_only_deal_with') }, inclusion: { in: YES_NO_ANSWER, :allow_blank => true }, if: :constructiondemolition_step?
  validates :registrationType, :presence => { :message => I18n.t('errors.messages.select_registration_type') }, inclusion: { in: %w(carrier_dealer broker_dealer carrier_broker_dealer), :allow_blank => true }, if: :registrationtype_step?
  validates :onlyAMF, :presence => { :message => I18n.t('errors.messages.select_only_deal_with') }, inclusion: { in: YES_NO_ANSWER, :allow_blank => true }, if: :onlydealwith_step?

  # *******************************************
  # * Section 2 (contact details) validations *
  # *******************************************

  # Validate company number (Limited Company in the UK)
  with_options if: [:businessdetails_step?, :limited_company?, :uk_limited_company?, :upper?] do |registration|
    registration.validates :company_no,
      uk_company_number: true
  end

  # Validate company name (any company type except Limited Company)
  with_options if: [:businessdetails_step?, :not_limited_company?] do |registration|
    registration.validates :companyName,
      presence: { message: I18n.t('errors.messages.blank_non_ltd_company_name') },
      format: {
        with: VALID_COMPANY_NAME_REGEX,
        message: I18n.t('errors.messages.invalid_company_name_characters'),
        allow_blank: true,
        maxLength: MAX_COMPANY_NAME_LENGTH
      },
      length: { maximum: MAX_COMPANY_NAME_LENGTH }
  end

  # Validate company name (Limited Company)
  with_options if: [:businessdetails_step?, :limited_company?] do |registration|
    registration.validates :companyName,
      presence: { message: I18n.t('errors.messages.blank_ltd_company_name') },
      format: {
        with: VALID_COMPANY_NAME_REGEX,
        message: I18n.t('errors.messages.invalid_company_name_characters'),
        allow_blank: true,
        maxLength: MAX_COMPANY_NAME_LENGTH
      },
      length: { maximum: MAX_COMPANY_NAME_LENGTH }
  end

  # Validate company number (Limited Company outside the UK)
  with_options if: [:businessdetails_step?, :limited_company?, :foreign_limited_company?, :upper?] do |registration|
    registration.validates :company_no,
      length: {
        maximum: MAX_FOREIGN_COMPANY_NUMBER_LENGTH,
        message: I18n.t('errors.messages.foreign_company_number_too_long', max: MAX_FOREIGN_COMPANY_NUMBER_LENGTH)
      }
  end

  # TODO AH - is position ever used?
  with_options if: :contactdetails_step? do |registration|
    registration.validates :firstName, :presence => { :message => I18n.t('errors.messages.blank_first_name') }, format: { with: FIRST_NAME_REGEX, message: I18n.t('errors.messages.invalid_first_name'), allow_blank: true}, length: { maximum: 35 }
    registration.validates :lastName, :presence => { :message => I18n.t('errors.messages.blank_last_name') }, format: { with: LAST_NAME_REGEX, message: I18n.t('errors.messages.invalid_last_name'), allow_blank: true }, length: { maximum: 35 }
    registration.validates :position, format: { with: POSITION_NAME_REGEX }, :allow_nil => true, :allow_blank => true
    registration.validates :phoneNumber, :presence => { :message => I18n.t('errors.messages.blank_telephone') }, format: { with: VALID_TELEPHONE_NUMBER_REGEX, message: I18n.t('errors.messages.invalid_telephone'), allow_blank: true }, length: { maximum: 20 }
  end

  # TODO AH - not sure if this is common one yet?
  validates :contactEmail, email: true, if: [:digital_route?, :contactdetails_step?]

  # ***************************************
  # * Section 3 (convictions) validations *
  # ***************************************
  validates :declaredConvictions, :presence => { :message => I18n.t('errors.messages.select_declared_convictions') }, inclusion: { in: YES_NO_ANSWER, :allow_blank => true }, if: :convictions_step?

  # *****************************************
  # * Section 4 (check details) validations *
  # *****************************************
  validates :declaration, :acceptance => { :message => I18n.t('errors.messages.confirm_declaration') }, if: 'confirmation_step? or upper_summary_step?'

  # ******************************************
  # * Section 5 (create account) validations *
  # ******************************************
  validates :accountEmail, :presence => { :message => I18n.t('errors.messages.your_blank_email') }, :email => { :message => I18n.t('errors.messages.invalid_email'), :allow_blank => true } , if: [:signup_step?, :sign_up_mode_present?]

  with_options if: [:signup_step?,  :do_sign_up?] do |registration|
    registration.validates :accountEmail, :confirmation => { :message => I18n.t('errors.messages.invalid_confirmation_email') }
    registration.validate :user_cannot_exist_with_same_account_email
  end

  with_options if: [:signup_step?, :sign_up_mode_present?] do |registration|
    registration.validates :password, :presence => { :message => I18n.t('errors.messages.blank_password') }
    registration.validates :password, :confirmation => { :message => I18n.t('errors.messages.invalid_confirmation_password') }
    registration.validate :validate_password
  end

  # **********************
  # * Common validations *
  # **********************


  validates! :tier, presence: true, inclusion: { in: %w(LOWER UPPER) }, if: :signup_step?
  validate :validate_key_people, if: :should_validate_key_people?

  validate :is_valid_account?, if: [:signin_step?, :sign_up_mode_present?]

  validates :copy_cards, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: :payment_step?
  validates :payment_type, :presence => true, if: :payment_step?

  validate :selected_address?, if: [:businessdetails_step?, :address_results?]

  def address_results?
    registered_address.address_results?
  end

  def selected_address?
    errors.add(
      :selectedAddress,
      I18n.t('errors.messages.address_not_selected')) if selectedAddress.blank?
  end

  validate :copy_cards_added_to_copy_card_only_order?
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

  def copy_cards_added_to_copy_card_only_order?
    if (copy_cards && copy_cards.to_i < 1) and copy_card_only_order
      errors.add(:copy_cards, I18n.t('errors.messages.no_copy_cards_selected'))
    end
    if !copy_cards and copy_card_only_order
      errors.add(:copy_cards, I18n.t('errors.messages.no_copy_cards_selected'))

    end
  end

  def should_validate_key_people?
    key_person_step? || key_people_step? || relevant_people_step?
  end

  def newOrRenew_step?
    current_step.inquiry.newOrRenew?
  end

  def enterRegNumber_step?
    current_step.inquiry.enterRegNumber?
  end

  def location_step?
    current_step.inquiry.location?
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

  def key_person_step?
    current_step.inquiry.key_person?
  end

  def key_people_step?
    current_step.inquiry.key_people?
  end

  def relevant_people_step?
    current_step.inquiry.relevant_people?
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
      Airbrake.notify(e)
      Rails.logger.debug e.message
    end

    route == 'DIGITAL'
  end

  def assisted_digital?
    begin
      route = self.try(:metaData).try(:first).try(:route)
    rescue Exception => e
      Airbrake.notify(e)
      Rails.logger.debug e.message
    end

    route == 'ASSISTED_DIGITAL'
  end

  def limited_company?
    businessType == 'limitedCompany'
  end

  def foreign_limited_company?
    return false unless limited_company?
    regAddress = registered_address
    (regAddress && regAddress.addressMode == 'manual-foreign')
  end

  def uk_limited_company?
    return false unless limited_company?
    regAddress = registered_address
    (!regAddress || (regAddress.addressMode != 'manual-foreign'))
  end

  def not_limited_company?
    businessType != 'limitedCompany'
  end

  def partnership?
    businessType == 'partnership'
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
      Airbrake.notify(e)
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

  def self.new_or_renew_options_for_select
    (REGISTRATION_TYPES.collect {|d| [I18n.t('registration_types.'+d), d]})
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
    current_step == 'declaration'
  end

  def pending?
    metaData && metaData.first && metaData.first.status == 'PENDING'
  end

  def activate!
    #Note: the actual status update will be performed in the service
    Rails.logger.debug "REGISTRATION::ACTIVATE! Activate registration for: #{uuid}, status #{metaData.first.status}"
    #
    # Removed manually setting as active from here as should be set in the
    # services, as such the only action required is to perform a save!
    #
    # metaData.first.update(status: 'ACTIVE')
    #
    save!
  end

  #only upper tier registrations can expire
  def expirable?
    upper?
  end

  def revoked?
    metaData.first.status == 'REVOKED'
  end

  def deleted?
    metaData.first.status == 'INACTIVE'
  end

  def refused?
    metaData.first.status == 'REFUSED'
  end

  def is_revocable?(agency_user=nil)
    is_complete? and user_can_edit_registration(agency_user)
  end

  def is_unrevocable?(agency_user=nil)
    metaData.first.status == "REVOKED" and user_can_edit_registration(agency_user)
  end

  def can_be_edited?(agency_user=nil)
    is_active? && user_can_edit_registration(agency_user)
  end

  def can_view_certificate?
    is_active?
  end

  def can_request_copy_cards?(agency_user=nil)
    metaData.first.status == 'ACTIVE' && upper? and user_can_edit_registration(agency_user)
  end

  def can_view_payment_status?
    # all users can view payment status
    true
  end

  def can_be_deleted?(agency_user)
    !deleted? and user_can_edit_registration(agency_user)
  end

  def can_be_approved?(agency_user=nil)
    (metaData.first.status == 'PENDING' && is_awaiting_conviction_confirmation?(agency_user)) || metaData.first.status == 'REFUSED'
  end

  def can_be_refused?(agency_user=nil)
    metaData.first.status == 'PENDING' && is_awaiting_conviction_confirmation?(agency_user)
  end

  def can_be_transferred?(agency_user)
    user_can_edit_registration(agency_user)
  end

  def user_can_edit_registration(agency_user)
    if agency_user and agency_user.is_agency_user?
      isEitherFinance = agency_user.has_any_role?({ :name => :Role_financeBasic, :resource => AgencyUser }, { :name => :Role_financeAdmin, :resource => AgencyUser })
      !isEitherFinance
    else
      true
    end
  end

  def validate_revokedReason
    #validate :validate_revokedReason, :if => lambda { |o| o.persisted? }
    Rails.logger.debug 'validate revokedReason, revoked:'
    # If revoke question is Yes, and revoke reason is empty, then error
    if revoked.present?
      if metaData.revokedReason.blank?
        Rails.logger.debug 'revokedReason is empty'
        errors.add(:revokedReason, I18n.t('errors.messages.blank') )
      end
    end
  end

  def user_cannot_exist_with_same_account_email
    errors.add(:accountEmail, I18n.t('errors.messages.email_already_in_use') ) if User.where(email: accountEmail).exists?
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
    metaData.first.dateActivated.presence.to_s
  end

  def getOrder(orderCode)
    Rails.logger.debug 'Registration getOrder ' + orderCode.to_s
    foundOrder = nil
    self.finance_details.first.orders.each do |order|
      Rails.logger.debug 'Order ' + order.orderCode.to_s
      if orderCode.to_i == order.orderCode.to_i
        Rails.logger.debug 'Registration Found order ' + orderCode.to_s
        foundOrder = order
      end
    end
    foundOrder
  end

  # Call to determine whether the registration is 'complete' i.e. there are no
  # outstanding checks, payment has been made and the account has been activated
  def is_complete?
    is_complete = true

    unless metaData.first.status == 'ACTIVE'
      Rails.logger.debug "REGISTRATION::IS_COMPLETE? status = #{metaData.first.status}"
      is_complete = false
      return
    end

    if is_awaiting_conviction_confirmation?
      is_complete = false
      return
    end

    unless paid_in_full?
      Rails.logger.debug "REGISTRATION::IS_COMPLETE? paid_in_full = #{paid_in_full?}"
      is_complete = false
      return
    end

    is_complete

  end

  def tier_and_registration_type_description
    if upper?
      I18n.t('registrations.view.upper_tier_registered_as',
        tier: tier.downcase.with_indefinite_article,
        regType: I18n.t('registrations.view.' + registrationType.to_s)
      )
    else
      I18n.t('registrations.view.lower_tier_registered_as',
        tier: tier.downcase.with_indefinite_article
      )
    end
  end

  UpperRegistrationStatus = %w[
    INACTIVE
    EXPIRED
    REVOKED
    REFUSED
    CONVICTIONS
    PENDINGPAYMENT
    COMPLETE
  ]

  LowerRegistrationStatus = %w[
    INACTIVE
    REVOKED
    PENDING
    COMPLETE
  ]

  def get_label_for_status( status)
    I18n.t('registration_status.' + status.to_s)
  end

  def registration_status
    if upper?
      # For UPPER:
      Rails.logger.debug "Upper registration " + uuid.to_s

      # Deleted
      if deleted?
        Rails.logger.debug "Upper registration " + companyName.to_s + " is deleted"
        get_label_for_status( UpperRegistrationStatus[0])
        # Expired
      elsif expired?
        Rails.logger.debug "Upper registration " + companyName.to_s + " has expired"
        get_label_for_status( UpperRegistrationStatus[1])
        # Revoked
      elsif revoked?
        Rails.logger.debug "Upper registration " + companyName.to_s + " is revoked"
        get_label_for_status( UpperRegistrationStatus[2])
        # Refused
      elsif refused?
        Rails.logger.debug "Upper registration " + companyName.to_s + " has been refused"
        get_label_for_status( UpperRegistrationStatus[3])
        # Conviction Check
      elsif is_awaiting_conviction_confirmation?
        get_label_for_status( UpperRegistrationStatus[4])
        # Awaiting Payment
      elsif !paid_in_full?
        Rails.logger.debug "Upper registration " + companyName.to_s + " is not paid"
        get_label_for_status( UpperRegistrationStatus[5])
        # Registered
      elsif is_complete?
        Rails.logger.debug "Upper registration " + companyName.to_s + " is complete"
        get_label_for_status( UpperRegistrationStatus[6])
      else
        # If all else fails .. PENDING
        Rails.logger.warn "Upper registration " + companyName.to_s + " is unable to determine status, use Pending"
        get_label_for_status( LowerRegistrationStatus[2])
      end
    else
      # For LOWER:
      Rails.logger.debug "Lower registration " + uuid.to_s

      # Deleted
      if deleted?
        get_label_for_status( LowerRegistrationStatus[0])
        # Revoked
      elsif revoked?
        get_label_for_status( LowerRegistrationStatus[1])
        # Pending
      elsif pending?
        get_label_for_status( LowerRegistrationStatus[2])
        # Registered
      elsif is_complete?
        get_label_for_status( LowerRegistrationStatus[3])
      else
        # If all else fails .. PENDING
        get_label_for_status( LowerRegistrationStatus[2])
      end
    end
  end

  def registration_status_color
    case registration_status
    when 'De-Registered'
      '#FF0000'
    when 'Registered'
      '#00823b'
    when 'Awaiting payment'
      '#e27300'
    else
      '#000000'
    end
  end

  def self.activate_registrations(user)
    Rails.logger.debug "Activating pending registrations for user with email"
    rs = Registration.find_by_email(user.email)
    Rails.logger.debug("found: #{rs.size} pending registrations")
    rs.each do |r|
      Registration.activate_registration(r)
      if r.lower?
        Registration.send_registered_email(user, r)
      end
    end #each
    Rails.logger.debug "Activated registration(s) for user with email"
    return rs
  end

  def self.isReadyToBeActive(reg)
    reg.paid_in_full? and !reg.is_awaiting_conviction_confirmation?
  end

  def self.isAwaitingPayment(reg)
    return !reg.paid_in_full?
  end

  def self.isAwaitingConvictions(reg)
    reg.upper? and reg.is_awaiting_conviction_confirmation?
  end

  def self.activate_registration(r)
    Rails.logger.debug "Check registration ready for activation"
    if r.pending? and Registration.isReadyToBeActive(r)
      Rails.logger.debug "Activating registration"
      r.activate!
      Rails.logger.debug "registration #{r.id} activated!"
    else
      Rails.logger.debug "Skipping non-pending registration"
    end
  end

  def self.send_registered_email(user, r)
    if Registration.isReadyToBeActive(r)
      #
      # NOTE:
      # Should be able to use the following but there is a bug that currently mean agency users are creating DIGITAL routes
      # Rails.logger.debug 'route: ' + r.metaData.first.route.to_s
      # if r.metaData.first.route == 'DIGITAL'
      #
      # FIXME: Replace the 'is_agency_user?', with 'r.metaData.first.route ...' once the above defect is resolved
      #
      if user and r.metaData.first.route == 'DIGITAL'
        Rails.logger.debug "Send registration email"
        RegistrationMailer.welcome_email(user,r).deliver_now
      else
        Rails.logger.debug "Registration not Digital or User not valid, thus registraion email not to be sent"
      end
    elsif Registration.isAwaitingPayment(r) and r.metaData.first.route == 'DIGITAL'
      # Send awaiting payment email
      RegistrationMailer.awaitingPayment_email(user, r).deliver_now
    elsif Registration.isAwaitingConvictions(r) and r.metaData.first.route == 'DIGITAL'
      # Send awaiting conviction check email
      RegistrationMailer.awaitingConvictionsCheck_email(user, r).deliver_now
    else
      Rails.logger.debug "Skipping sending registered email"
    end
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

  def validate_key_people
    if relevant_people_step?
      if key_people.select { |person| person.person_type == 'RELEVANT'}.empty?
        errors.add(:key_people, I18n.t('errors.messages.enter_at_least_1_relevant_person'))
      end
    elsif key_person_step? || key_people_step?
      local_key_people = key_people.select { |person| person.person_type == 'KEY'}
      if partnership? && (local_key_people.size < 2)
        errors.add(:key_people, I18n.t('errors.messages.enter_at_least_2_partners'))
      elsif local_key_people.empty?
        errors.add(:key_people, I18n.t('errors.messages.enter_at_least_1_key_person'))
      end
    end
  end

  # For Upper Tier registrations, returns an array containing the names of the
  # Key People (but excluding Relevant People).  For Lower Tier registrations,
  # returns a single-element array containing the contact name.
  def get_tier_appropriate_key_people_array
    result = []
    if tier == 'UPPER'
      result = key_people
        .select { |person| person.person_type == 'KEY' }
        .map    { |person| format('%s %s', person.first_name, person.last_name) }
    elsif tier == 'LOWER'
      result.push(format('%s %s', firstName, lastName))
    end
    result
  end

  # Changes the registration's status to INACTIVE
  # i.e. a 'soft' delete
  #
  # @return [Boolean] true if update successful
  def set_inactive
    metaData.first.update(status: 'INACTIVE')
    save!
  end

  def is_active?
    return false unless metaData.present?
    metaData.first.status == 'ACTIVE'
  end

  def is_inactive?
    metaData.first.status == 'INACTIVE'
  end

  def get_status
    metaData.first.status
  end

  def registered_address
    # Finds the first element that matches and returns it
    addresses.to_a.find { |address| address.addressType == 'REGISTERED' }
  end

  def postal_address
    # Finds the first element that matches and returns it
    addresses.to_a.find { |address| address.addressType == 'POSTAL' }
  end

  def copy_card_orders
    # returns an array of copy card orders
    finance_details.first.orders.to_a.select {
      |order| order.order_items.to_a.any? {
        |order_item| order_item.type == 'COPY_CARDS'
      }
    }
  end

  def registration_order
    RegistrationOrder.new(self)
  end

  def order_builder
    OrderBuilder.new(registration_order)
  end

  def order_types
    registration_order.order_types
  end

  def latest_order
    finance_details.first.orders.to_a.last
  end

  # This is just true for matching external users, not agency users or other backend users
  def account_email_has_no_matching_user?
    return true if accountEmail.blank?
    return false if User.where(email: accountEmail).count.positive?
    true
  end
end
