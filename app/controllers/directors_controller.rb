class DirectorsController < ApplicationController

  # GET /your-registration/directors
  def directorDetails
    @director = Director.new
  end

  # POST /your-registration/directors
  def create
    get_registration

    logger.debug @registration.directors.length
    @registration.directors.each { |d| logger.debug "#{d.first_name} #{d.last_name}" }

    director = Director.new(params[:director])

    if director.valid?
      @registration.directors << director
      logger.info 'Director is valid so far, go to next page'
      render :directorDetails
    else
      # there is an error (but data not yet saved)
      logger.info 'Director is not valid, and data is not yet saved'
      render "directorDetails", :status => '400'
    end
  end

  # PATCH/PUT /your-registration/directors/:id
  def update
    set_action

    if @director.valid?
      logger.info 'Director is valid so far, go to next page'
      redirect_to :upper_payment
    elsif @director.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Director is not valid, and data is not yet saved'
      render "directorDetails", :status => '400'
    end
  end

  # DELETE /your-registration/directors/:id
  def delete
    redirect_to :upper_payment
  end

  # POST /your-registration/directors/done
  def done
    set_action

    if @director.valid?
      logger.info 'Director is valid so far, go to next page'
      redirect_to :upper_payment
    elsif @director.new_record?
      # there is an error (but data not yet saved)
      logger.info 'Director is not valid, and data is not yet saved'
      render "directorDetails", :status => '400'
    end
  end

  def get_registration
    session[:registration_params] ||= {}
    @registration = Registration.new(session[:registration_params])
    unless @registration.has_attribute?(:directors)
      @registration.directors = []
      session[:registration_params] = @registration
    end
  end

  def get_action
    session[:directors] ||= []
    @directors = session[:directors]
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