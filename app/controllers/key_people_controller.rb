require 'securerandom'

class KeyPeopleController < ApplicationController

  # GET /your-registration/key-people/registration
  def registration
    get_registration

    if @registration.businessType == 'soleTrader'
      redirect_to action: 'newKeyPerson'
    else
      redirect_to action: 'newKeyPeople'
    end
  end

  # GET /your-registration/key-person
  def newKeyPerson
    get_registration
    get_key_people

    if @key_people.empty?
      @key_person = KeyPerson.create
    else
      @key_person = @key_people.first
    end
  end

  # POST /your-registration/key-person
  def updateNewKeyPerson
    get_registration

    @key_person = KeyPerson.create
    @key_person.add(params[:key_person])

    if @key_person.valid?
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
    get_registration
    get_key_people

    @key_person = KeyPerson.create
  end

  # POST /your-registration/key-people
  def updateNewKeyPeople
    get_registration

    @key_person = KeyPerson.create
    @key_person.add(params[:key_person])

    if @key_person.valid?
      @key_person.save
      @registration.key_people.add(@key_person)
      @registration.save
      redirect_to action: 'newKeyPeople'
    else
      # there is an error (but data not yet saved)
      logger.info 'Key person is not valid, and data is not yet saved'
      render "newKeyPeople", :status => '400'
    end
  end

  # GET /key-people/delete/:id
  def delete
    get_registration

    key_person_to_remove = KeyPerson[params[:id]]
    logger.debug "reg is: #{@registration.id}"
    logger.debug "key person to remove is: #{key_person_to_remove.id}"

    @registration.key_people.delete(key_person_to_remove)

    redirect_to action: 'registration'
  end

  # POST /your-registration/key-people/done
  def done
    redirect_to :newRelevantConvictions
  end

  # GET /your-registration/key-people
  def index
    get_registration
    get_key_people
  end

  # GET /your-registration/key-people/:id
  def show
  end

  # GET /your-registration/key-people/new
  def new
    get_key_people
    @key_person = Registration::KeyPerson.create
  end

  # GET /key-people/edit/:id
  def edit
    get_key_people
    @key_person = Registration::KeyPerson[params[:id]]
    logger.debug "id to update: #{params[:id]}"
    session[:key_person_update_id] = params[:id]
  end

  # DELETE /key-person/:id
  def destroy
    get_key_person
  end

  # POST /your-registration/key-people/done
  def done
    redirect_to :newRelevantConvictions
  end

  def get_registration
    @registration = Registration[session[:registration_id]]
    logger.debug "get_registration: #{@registration.attributes.to_s}"
  end

  def get_key_people
    @key_people = @registration.key_people.to_a
    logger.debug "get_key_people: #{@key_people.to_s}"
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
