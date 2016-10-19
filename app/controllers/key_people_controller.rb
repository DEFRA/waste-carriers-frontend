class KeyPeopleController < ApplicationController
  include RegistrationsHelper

  # GET /your-registration/:reg_uuid/key-people/registration
  def registration
    setup_registration('key_people')
    render_not_found and return unless @registration

    if @registration.businessType == 'soleTrader'
      redirect_to action: :key_person
    else
      redirect_to action: :key_people
    end
  end

  # GET /your-registration/:reg_uuid/key-person
  def key_person
    setup_registration('key_person')
    render_not_found and return unless @registration
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
    setup_registration('key_person')
    render_not_found and return unless @registration
    get_key_people

    @key_person = KeyPerson.create
    @key_person.add(params[:key_person])

    if @key_person.valid?
      @key_person.cross_check_convictions
      @key_person.save

      # Create a list of all non key people (ie.'RELEVANT'), to ensure they are
      # retained when the list is replaced.  We are assuming that the only 'KEY'
      # person is the key person from the params which we add after.
      person_list = Array.new
      @registration.key_people.each do |key_person|
        person_list.push(key_person) unless key_person.person_type == "KEY"
      end
      # Add key person from params
      person_list.push(@key_person)

      @registration.key_people.replace(person_list)
      @registration.save

      redirect_to :relevant_convictions
    else
      # there is an error (but data not yet saved)
      logger.debug 'Key person is not valid, and data is not yet saved'
      render :key_person, status: :bad_request
    end
  end

  # GET /your-registration/:reg_uuid/key-people
  def key_people
    setup_registration('key_people')
    render_not_found and return unless @registration
    get_key_people

    # Check if we should force a validation of the key_people attribute on the
    # registration.  We do this to trigger the validation message for a
    # Partnership with < 2 partners.
    if session.key?(:performKeyPeopleValidation) && (session[:performKeyPeopleValidation] == @registration.reg_uuid)
      @registration.validate_key_people()
      session.delete(:performKeyPeopleValidation)
    end

    @key_person = KeyPerson.create
  end

  # POST /your-registration/key-people
  def update_key_people
    setup_registration('key_people')
    render_not_found and return unless @registration
    get_key_people

    @key_person = KeyPerson.create
    @key_person.add(params[:key_person])

    unless (params[:add] || params[:continue])
      logger.warn {'updateNewKeyPeople: unrecognised button found, sending back to newKeyPeople page'}
      render :key_people, status: :bad_request and return
    end

    if @key_person.valid?
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
          # Key People attribute on the registration.  This allows the page to
          # display all the required information.
          session[:performKeyPeopleValidation] = @registration.reg_uuid
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
        render :key_people, status: :bad_request
      else
        @key_person.errors.clear
        unless @registration.valid?
          # We have too few Key People added so far.
          render :key_people, status: :bad_request
        else
          # Everything is OK; continue to next page.
          redirect_to :relevant_convictions
        end
      end
    else
      # Key Person details are not blank, but failed validation.
      render :key_people, status: :bad_request
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
    setup_registration('relevant_people')
    render_not_found and return unless @registration
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

          redirect_to action: :relevant_people
        else
          # there is an error (but data not yet saved)
          logger.debug 'Registration is not valid, and data is not yet saved'
          render :relevant_people, status: :bad_request
        end
      else
        # there is an error (but data not yet saved)
        logger.debug 'Relevant person is not valid, and data is not yet saved'
        render :relevant_people, status: :bad_request
      end
    elsif params[:continue]
      if @key_person.valid?

        @key_person.cross_check_convictions
        @key_person.save

        @registration.key_people.add(@key_person)

        if @registration.valid?
          @registration.save

          redirect_to declaration_path(reg_uuid: @registration.reg_uuid)
        else
          # there is an error (but data not yet saved)
          logger.debug '1 Registration is not valid, and data is not yet saved'
          render :relevant_people, status: :bad_request
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
            logger.debug '2 Key person is not valid, and data is not yet saved'
            render :relevant_people, status: :bad_request
          else
            # Not 1st person and Form is blank so can go to declaration
            redirect_to declaration_path(reg_uuid: @registration.reg_uuid)
          end
        else
          # there is an error (but data not yet saved)
          logger.debug '3 Key person is not valid, and data is not yet saved'
          render :relevant_people, status: :bad_request
        end
      end
    else
      logger.debug 'Unrecognised button found, sending back to newRelevantPeople page'
      render :relevant_people, status: :bad_request
    end
  end

  # GET /your-registration/:reg_uuid/key-people/:id/delete
  def delete_key_person
    setup_registration('key_people')
    render_not_found and return unless @registration

    key_person_to_remove = KeyPerson[params[:id]]
    render_not_found and return unless key_person_to_remove

    @registration.key_people.delete(key_person_to_remove)

    redirect_to action: :registration
  end

  # GET /your-registration/:reg_uuid/relevant-people/:id/delete
  def delete_relevant_person
    setup_registration('relevant_people')
    render_not_found and return unless @registration

    person_to_remove = KeyPerson[params[:id]]
    render_not_found and return unless person_to_remove

    @registration.key_people.delete(person_to_remove)

    redirect_to action: :relevant_people
  end

  # GET /your-registration/:reg_uuid/key-people
  def index
    setup_registration('key_people')
    render_not_found and return unless @registration

    get_key_people
  end

  # DELETE /your-registration/:reg_uuid/key-person/:id
  def destroy
    setup_registration('key_person')
    render_not_found and return unless @registration

    get_key_person
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
