require 'securerandom'

class KeyPeopleController < ApplicationController
  include RegistrationsHelper

  before_action :get_registration, except: [:doneKeyPeople, :doneRelevantPeople]

  # GET /your-registration/key-people/registration
  def registration
    #get_registration

    if @registration.businessType == 'soleTrader'
      redirect_to action: 'newKeyPerson'
    else
      redirect_to action: 'newKeyPeople'
    end
  end

  # GET /your-registration/key-person
  def newKeyPerson
    #get_registration
    new_step_action 'key_person'
    get_key_people

    if @key_people.empty?
      @key_person = KeyPerson.create
    else
      @key_person = @key_people.first
      Rails.logger.debug "key_person: #{@key_person.attributes.to_s}"
    end
  end

  # POST /your-registration/key-person
  def updateNewKeyPerson
    #get_registration
    get_key_people

    @key_person = KeyPerson.create
    @key_person.add(params[:key_person])

    if @key_person.valid?

      @key_person.cross_check_convictions
      @key_person.save

      @registration.key_people.replace([@key_person])
      @registration.save

      redirect_to :newRelevantConvictions
    else
      # there is an error (but data not yet saved)
      logger.info 'Key person is not valid, and data is not yet saved'
      render "newKeyPerson", :status => '400'
    end
  end

  # GET /your-registration/key-people
  def newKeyPeople
    new_step_action 'key_people'
    get_key_people

    @key_person = KeyPerson.create
  end

  # POST /your-registration/key-people
  def updateNewKeyPeople
    get_key_people

    @key_person = KeyPerson.create
    @key_person.add(params[:key_person])

    if params[:add]

      if @key_person.valid?

        @key_person.cross_check_convictions
        @key_person.save

        @registration.key_people.add(@key_person)

        if @registration.valid?
          @registration.save

          redirect_to action: 'newKeyPeople'
        else
          # there is an error (but data not yet saved)
          logger.info 'Registration is not valid, and data is not yet saved'
          render "newKeyPeople", :status => '400'
        end
      else
        # there is an error (but data not yet saved)
        logger.info 'Key person is not valid, and data is not yet saved'
        render "newKeyPeople", :status => '400'
      end
    elsif params[:next]
      if @key_person.valid?

        @key_person.cross_check_convictions
        @key_person.save

        @registration.key_people.add(@key_person)

        if @registration.valid?
          @registration.save

          redirect_to :newRelevantConvictions
        else
          # there is an error (but data not yet saved)
          logger.info 'Registration is not valid, and data is not yet saved'
          render "newKeyPeople", :status => '400'
        end
      elsif @key_person.first_name.blank?
        @key_person.errors.clear

        # Assume the person has not entered anything and just wants to
        # progress to the next step. We still have to check they have entered
        # at least one person
        if @registration.valid?
          @registration.save

          redirect_to :newRelevantConvictions
        else
          # there is an error (but data not yet saved)
          logger.info 'Registration is not valid, and data is not yet saved'
          render "newKeyPeople", :status => '400'
        end
      else
        # there is an error (but data not yet saved)
        logger.info 'Key person is not valid, and data is not yet saved'
        render "newKeyPeople", :status => '400'
      end
    else
      logger.info 'Unrecognised button found, sending back to newKeyPeople page'
      render "newKeyPeople", :status => '400'
    end
  end

  # GET /your-registration/relevant-people
  def newRelevantPeople
    new_step_action 'relevant_people'
    get_relevant_people

    @key_person = KeyPerson.create
  end

  # POST /your-registration/relevant-people
  def updateNewRelevantPeople
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
          logger.info 'Registration is not valid, and data is not yet saved'
          render "newRelevantPeople", :status => '400'
        end
      else
        # there is an error (but data not yet saved)
        logger.info 'Relevant person is not valid, and data is not yet saved'
        render "newRelevantPeople", :status => '400'
      end
    elsif params[:next]
      if @key_person.valid?

        @key_person.cross_check_convictions
        @key_person.save

        @registration.key_people.add(@key_person)

        if @registration.valid?
          @registration.save

          redirect_to :newConfirmation
        else
          # there is an error (but data not yet saved)
          logger.info 'Registration is not valid, and data is not yet saved'
          render "newRelevantPeople", :status => '400'
        end
      elsif @key_person.first_name.blank?
        @key_person.errors.clear

        # Assume the person has not entered anything and just wants to
        # progress to the next step. We still have to check they have entered
        # at least one person
        if @registration.valid?
          @registration.save

          redirect_to :newConfirmation
        else
          # there is an error (but data not yet saved)
          logger.info 'Registration is not valid, and data is not yet saved'
          render "newRelevantPeople", :status => '400'
        end
      else
        # there is an error (but data not yet saved)
        logger.info 'Key person is not valid, and data is not yet saved'
        render "newRelevantPeople", :status => '400'
      end
    else
      logger.info 'Unrecognised button found, sending back to newRelevantPeople page'
      render "newRelevantPeople", :status => '400'
    end
  end

  # GET /your-registration/key-people/delete/:id
  def delete
    key_person_to_remove = KeyPerson[params[:id]]
    if !key_person_to_remove
      renderNotFound
      return
    end

    logger.debug "reg is: #{@registration.id}"
    logger.debug "key person to remove is: #{key_person_to_remove.id}"

    @registration.key_people.delete(key_person_to_remove)

    redirect_to action: 'registration'
  end

  # GET /your-registration/relevant-people/delete/:id
  def deleteRelevantPerson
    person_to_remove = KeyPerson[params[:id]]
    if !person_to_remove
      renderNotFound
      return
    end    
    logger.debug "reg is: #{@registration.id}"
    logger.debug "relevant person to remove is: #{person_to_remove.id}"

    @registration.key_people.delete(person_to_remove)

    redirect_to action: 'newRelevantPeople'
  end

  # GET /your-registration/key-people
  def index
    get_key_people
  end

  # DELETE /key-person/:id
  def destroy
    get_key_person
  end

  def get_registration
    @registration = Registration[session[:registration_id]]
    if !@registration
      renderNotFound
    end
  end

  def get_key_people
    @key_people = @registration.key_people.to_a.find_all{ |person| person.person_type == 'KEY' }
  end

  def get_relevant_people
    @relevant_people = @registration.key_people.to_a.find_all{ |person| person.person_type == 'RELEVANT' }
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
