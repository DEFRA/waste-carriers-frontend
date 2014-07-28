require 'securerandom'

class DirectorsController < ApplicationController

  # GET /your-registration/directors
  def registration
    get_registration
    unless @registration.businessType == "limitedCompany"
      redirect_to :upper_payment
      return
    end
    get_directors
    unless @directors.empty?
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
    @director = Registration::Director.create
  end

  # GET /directors/edit/:id
  def edit
    get_directors
    @director = Registration::Director[params[:id]]
    logger.debug "id to update: #{params[:id]}"
    session[:director_update_id] = params[:id]
    # @director = @directors.find { |d| d.temp_id == params[:id]}
  end

  # GET /directors/delete/:id
  def delete
    get_directors
    director_to_remove = Registration::Director[params[:id]]
logger.debug "reg is: #{@registration.id}"
logger.debug "director_to_remove is: #{director_to_remove.id}"

    @registration.directors.delete(director_to_remove)

    if @registration.directors.to_a.empty?
      redirect_to action: 'registration'
    else
      redirect_to action: 'index'
    end

  end

  # POST /your-registration/directors
  def create
    get_directors

    director = Registration::Director.create
    director.set_attribs(params[:director])



    if director.valid?
      director.save
      logger.debug @registration.id
      @registration.directors.add(director )
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

    director = Registration::Director[ session[:director_update_id]]
    director.set_attribs(params[:director])


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
    redirect_to :upper_summary
  end

  def get_registration

    @registration = Registration[ session[:registration_id]]
    logger.debug  @registration.attributes.to_s
  end

  def get_directors
    # session[:directors] ||= []
    # @directors = session[:directors]
    @registration = Registration[ session[:registration_id]]
    @directors = @registration.directors.to_a
    logger.debug  @directors.to_s
  end

  def set_directors
    session[:directors] ||= @directors
  end

  private

  ## 'strong parameters' - whitelisting parameters allowed for mass assignment from UI web pages
  def director_params
    params.require(:director).permit(
      :first_name,
      :last_name,
      :dob_day,
      :dob_month,
    :dob_year)
  end

end
