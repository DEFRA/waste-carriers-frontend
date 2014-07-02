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
    @director = Director.new
  end

  # GET /directors/edit/:id
  def edit
    get_directors

    @director = @directors.find { |d| d.temp_id == params[:id]}
  end

  # GET /directors/delete/:id
  def delete
    get_directors

    @director = @directors.find { |d| d.temp_id == params[:id]}

    index = @directors.index { |d| d.temp_id == params[:id]}
    @directors.delete_at index

    if @directors.empty?
      redirect_to action: 'registration'
    else
      redirect_to action: 'index'
    end

  end

  # POST /your-registration/directors
  def create
    get_directors

    director = Director.new(params[:director])

    if director.valid?
      director.temp_id = SecureRandom.hex(4)
      @directors << director
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

    @director = Director.new(params[:director])

    if @director.valid?

      index = @directors.index { |d| d.temp_id == @director.temp_id}
      logger.debug "Index was #{index}"
      @directors[index] = @director
      logger.info 'Director is valid so far, go to next page'
      render 'index'
    elsif @director.new_record?
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
    redirect_to :upper_payment
  end

  def get_registration
    session[:registration_params] ||= {}
    @registration = Registration.new(session[:registration_params])
  end

  def get_directors
    session[:directors] ||= []
    @directors = session[:directors]
  end

  def set_directors
    session[:directors] ||= @directors
  end

  def set_action
    session[:directors] ||= []
    @directors = session[:directors]
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