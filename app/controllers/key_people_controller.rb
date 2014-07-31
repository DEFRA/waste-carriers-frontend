require 'securerandom'

class KeyPeopleController < ApplicationController

  # GET /your-registration/key-people
  def registration
    get_registration
    unless @registration.businessType == "limitedCompany"
      redirect_to :upper_payment
      return
    end
    get_key_people
    redirect_to action: 'new'
  end

  # GET /your-registration/key-people
  def index
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

  # GET /key-people/delete/:id
  def delete
    get_key_people
    key_person_to_remove = Registration::KeyPerson[params[:id]]
    logger.debug "reg is: #{@registration.id}"
    logger.debug "key person to remove is: #{key_person_to_remove.id}"

    @registration.key_people.delete(key_person_to_remove)

    redirect_to action: 'new'
  end

  # POST /your-registration/key-people
  def create
    get_key_people

    @key_person = Registration::KeyPerson.create
    @key_person.set_attribs(params[:key_person])



    if @key_person.valid?
      @key_person.save
      logger.debug @registration.id
      @registration.key_people.add(@key_person)
      @registration.save

      redirect_to action: 'new'
    else
      # there is an error (but data not yet saved)
      logger.info 'Key person is not valid, and data is not yet saved'
      render 'new'
    end
  end

  # PATCH/PUT /your-registration/key-person/:id
  def update
    get_key_people

    key_person = Registration::KeyPerson[ session[:key_person_update_id]]
    key_person.set_attribs(params[:key_person])


    if key_person.valid?
      key_person.save
      logger.debug  key_person.attributes.to_s
      logger.info 'Key person is valid so far, go to next page'
      render 'index'
    else
      # there is an error (but data not yet saved)
      logger.info 'Key person is not valid, and data is not yet saved'
      render "edit", :status => '400'
    end
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
    logger.debug  @registration.attributes.to_s
  end

  def get_key_people
    @registration = Registration[session[:registration_id]]
    @key_people = @registration.key_people.to_a
    logger.debug  @key_people.to_s
  end

  def set_key_people
    session[:key_people] ||= @key_people
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
