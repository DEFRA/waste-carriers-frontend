class KeyPeopleController < ApplicationController
  include RegistrationsHelper

  before_action :get_registration, except: [:doneKeyPeople, :doneRelevantPeople]

  # GET /your-registration/:reg_uuid/key-people/registration
  def registration
    if @registration.businessType == 'soleTrader'
      redirect_to action: :key_person
    else
      redirect_to action: :key_people
    end
  end

  # GET /your-registration/:reg_uuid/key-person
  def key_person
    new_step_action 'key_person'
    return unless @registration
    get_key_people

    if @key_people.empty?
      @key_person = KeyPerson.create
      if @registration.businessType == 'soleTrader'
        @key_person.first_name = @registration.firstName
        @key_person.last_name = @registration.lastName
      end
    else
      @key_person = @key_people.first
    end
  end

  # POST /your-registration/key-person
  def update_key_person
    get_key_people

    @key_person = KeyPerson.create
    @key_person.add(params[:key_person])

    if @key_person.valid?
      @key_person.cross_check_convictions
      @key_person.save

      # Create a list of all non key people (ie.'RELEVANT'), to ensure they are
      # retained when the list is replaced.  We are assuming that the only 'KEY'
      # person is the key person from the params which we add after.
      personList = Array.new
      @registration.key_people.each do |kPerson|
        if !kPerson.person_type.eql? "KEY"
          personList.push(kPerson)
        end
      end
      # Add key person from params
      personList.push(@key_person)

      @registration.key_people.replace(personList)
      @registration.save

      redirect_to :relevant_convictions
    else
      # there is an error (but data not yet saved)
      logger.debug 'Key person is not valid, and data is not yet saved'
      render "newKeyPerson", :status => '400'
    end
  end

  # GET /your-registration/:reg_uuid/key-people
  def key_people
    new_step_action 'key_people'
    return unless @registration
    get_key_people

    # Check if we should force a validation of the key_people attribute on the
    # registration.  We do this to trigger the validation message for a
    # Partnership with < 2 partners.
    if session.key?(:performKeyPeopleValidation)
      @registration.validate_key_people()
      session.delete(:performKeyPeopleValidation)
    end

    @key_person = KeyPerson.create
  end

  # POST /your-registration/key-people
  def update_key_people
    get_key_people

    @key_person = KeyPerson.create
    @key_person.add(params[:key_person])

    if !(params[:add] || params[:continue])
      logger.warn {'updateNewKeyPeople: unrecognised button found, sending back to newKeyPeople page'}
      render 'newKeyPeople', status: '400'
    elsif @key_person.valid?
      @key_person.cross_check_convictions
      @key_person.save
      @registration.key_people.add(@key_person)
      @registration.save

      if params[:continue]
        if @registration.valid?
          # Everything is OK; continue to next page.
          redirect_to :relevant_convictions
        else
          # User wanted to continue, but they haven't added enough Key People.
          # We set a variable in the session to force the re-validation of the
          # Key People attribute on the registraiton.  This allows the page to
          # display all the required information.
          session[:performKeyPeopleValidation] = true
          redirect_to :back
        end
      else
        # User wants to add another Key Person.
        redirect_to :back
      end
    elsif form_blank?
      # Form was left blank.
      if params[:add]
        # The user clicked the 'add' button but didn't provide any details.
        render :key_people, status: '400'
      else
        @key_person.errors.clear
        unless @registration.valid?
          # We have too few Key People added so far.
          render :key_people, status: '400'
        else
          # Everything is OK; continue to next page.
          redirect_to :relevant_convictions
        end
      end
    else
      # Key Person details are not blank, but failed validation.
      render :key_people, status: '400'
    end
  end

  # GET /your-registration/:reg_uuid/relevant-people
  def relevant_people
    new_step_action 'relevant_people'
    return unless @registration
    get_relevant_people

    @key_person = KeyPerson.create
  end

  # POST /your-registration/relevant-people
  def update_relevant_people
    get_relevant_people

    @key_person = KeyPerson.create
    @key_person.add(params[:key_person])

    if params[:add]
      if @key_person.valid?

        @key_person.cross_check_convictions
        @key_person.save

        @registration.key_people.add(@key_person)
        if @registration.valid?
          @registration.save

          redirect_to action: 'newRelevantPeople'
        else
          # there is an error (but data not yet saved)
          logger.debug 'Registration is not valid, and data is not yet saved'
          render "newRelevantPeople", :status => '400'
        end
      else
        # there is an error (but data not yet saved)
        logger.debug 'Relevant person is not valid, and data is not yet saved'
        render "newRelevantPeople", :status => '400'
      end
    elsif params[:continue]
      if @key_person.valid?

        @key_person.cross_check_convictions
        @key_person.save

        @registration.key_people.add(@key_person)

        if @registration.valid?
          @registration.save

          redirect_to :confirmation
        else
          # there is an error (but data not yet saved)
          logger.debug 'Registration is not valid, and data is not yet saved'
          render "newRelevantPeople", :status => '400'
        end
      else
        # No data entered
        if form_blank?

          # 1st person
          if @relevant_people.empty?
            @key_person.errors.clear

            # TODO AH adds "You must add at least 1 person...." message - could this be done in here?
            @registration.valid?

            # there is an error (but data not yet saved)
            logger.debug 'Key person is not valid, and data is not yet saved'
            render "newRelevantPeople", :status => '400'
          else
            # Not 1st person and Form is blank so can go to declaration
            redirect_to :confirmation
          end
        else
          # there is an error (but data not yet saved)
          logger.debug 'Key person is not valid, and data is not yet saved'
          render "newRelevantPeople", :status => '400'
        end
      end
    else
      logger.debug 'Unrecognised button found, sending back to newRelevantPeople page'
      render "newRelevantPeople", :status => '400'
    end
  end

  # GET /your-registration/:reg_uuid/key-people/delete/:id
  def delete
    key_person_to_remove = KeyPerson[params[:id]]
    if !key_person_to_remove
      renderNotFound
      return
    end

    @registration.key_people.delete(key_person_to_remove)

    redirect_to action: 'registration'
  end

  # GET /your-registration/:reg_uuid/relevant-people/delete/:id
  def delete_relevant_person
    person_to_remove = KeyPerson[params[:id]]
    if !person_to_remove
      renderNotFound
      return
    end

    @registration.key_people.delete(person_to_remove)

    redirect_to action: 'newRelevantPeople'
  end

  # GET /your-registration/:reg_uuid/key-people
  def index
    get_key_people
  end

  # DELETE /key-person/:id
  def destroy
    get_key_person
  end

  def get_registration
    setup_registration 'key_people'
    unless @registration
      renderNotFound
    end
  end

  def get_key_people
    @key_people = @registration.key_people.to_a.find_all{ |person| person.person_type == 'KEY' }
  end

  def get_relevant_people
    @relevant_people = @registration.key_people.to_a.find_all{ |person| person.person_type == 'RELEVANT' }
  end

  def form_blank?
    (@key_person.first_name.empty?) &&
      (@key_person.last_name.empty?) &&
      (@key_person.dob_day.empty?) &&
      (@key_person.dob_month.empty?) &&
      (@key_person.dob_year.empty?)
  end

  private

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment from UI web pages
  def key_person_params
    params.require(:key_person).permit(
      :first_name,
      :last_name,
      :dob_day,
      :dob_month,
      :dob_year)
  end

end
