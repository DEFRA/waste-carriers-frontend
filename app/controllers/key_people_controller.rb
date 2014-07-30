require 'securerandom'

class KeyPeopleController < ApplicationController

  # GET /your-registration/directors
  def registration
    get_registration
    unless @registration.businessType == "limitedCompany"
      redirect_to :upper_payment
      return
    end
    get_directors
    unless @key_people.empty?
      redirect_to action: 'index'
      return
    end
    redirect_to action: 'new'
  end

  # GET /your-registration/directors
  def index
    get_directors
  end

  # GET /your-registration/directors/:id
  def show
  end

  # GET /your-registration/directors/new
  def new
    # @director = Director.new
    # @registration = Registration[ session[:registration_id]]
    @key_person = Registration::KeyPerson.create
  end

  # GET /directors/edit/:id
  def edit
    get_directors
    @key_person = Registration::KeyPerson[params[:id]]
    logger.debug "id to update: #{params[:id]}"
    session[:director_update_id] = params[:id]
    # @director = @directors.find { |d| d.temp_id == params[:id]}
  end

  # GET /directors/delete/:id
  def delete
    get_directors
    director_to_remove = Registration::KeyPerson[params[:id]]
logger.debug "reg is: #{@registration.id}"
logger.debug "director_to_remove is: #{director_to_remove.id}"

    @registration.key_people.delete(director_to_remove)

    if @registration.key_people.to_a.empty?
      redirect_to action: 'registration'
    else
      redirect_to action: 'index'
    end

  end

  # POST /your-registration/directors
  def create
    get_directors

    director = Registration::KeyPerson.create
    director.set_attribs(params[:key_person])



    if director.valid?
      director.save
      logger.debug @registration.id
      @registration.key_people.add(director )
      @registration.save

      logger.info 'Director is valid so far, go to next page'
      render 'index'
    else
      # there is an error (but data not yet saved)
      logger.info 'Director is not valid, and data is not yet saved'
      render :new, :status => '400'
    end
  end

  # PATCH/PUT /your-registration/directors/:id
  def update
    get_directors

    # @director = Director.new(params[:director])

    director = Registration::KeyPerson[ session[:director_update_id]]
    director.set_attribs(params[:key_person])


    if director.valid?
      director.save
      logger.debug  director.attributes.to_s
      logger.info 'Director is valid so far, go to next page'
      render 'index'
    else
      # there is an error (but data not yet saved)
      logger.info 'Director is not valid, and data is not yet saved'
      render "edit", :status => '400'
    end
  end

  # DELETE /directors/:id
  def destroy
    get_directors
  end

  # POST /your-registration/directors/done
  def done
    redirect_to :newRelevantConvictions
  end

  def get_registration

    @registration = Registration[ session[:registration_id]]
    logger.debug  @registration.attributes.to_s
  end

  def get_directors
    # session[:directors] ||= []
    # @directors = session[:directors]
    @registration = Registration[ session[:registration_id]]
    @key_people = @registration.key_people.to_a
    logger.debug  @key_people.to_s
  end

  def set_directors
    session[:key_people] ||= @key_people
  end

  private

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment from UI web pages
  def director_params
    params.require(:key_person).permit(
      :first_name,
      :last_name,
      :dob_day,
      :dob_month,
    :dob_year)
  end

end
