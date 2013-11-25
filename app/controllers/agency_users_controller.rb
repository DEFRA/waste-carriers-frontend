#Controller for resource-oriented CRUD operations on agency users (a.k.a. internal users) 

class AgencyUsersController < ApplicationController

  ##TODO Uncomment filters when ready

  #before_filter :require_admin_request!


  #Only administrators can manage other users - requires administrator login.
  before_filter :authenticate_admin!

  before_action :set_agency_user, only: [:show, :edit, :update, :confirm_delete, :destroy]

  # GET /agency_users
  # GET /agency_users.json
  def index
    @agency_users = AgencyUser.all
  end

  # GET /agency_users/1
  # GET /agency_users/1.json
  def show
  end

  # GET /agency_users/new
  def new
    @agency_user = AgencyUser.new
  end

  # GET /agency_users/1/edit
  def edit
  end

  # POST /agency_users
  # POST /agency_users.json
  def create
    @agency_user = AgencyUser.new(agency_user_params)

    respond_to do |format|
      if @agency_user.save
        format.html { redirect_to @agency_user, notice: 'Agency user was successfully created.' }
        format.json { render action: 'show', status: :created, location: @agency_user }
      else
        format.html { render action: 'new' }
        format.json { render json: @agency_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /agency_users/1
  # PATCH/PUT /agency_users/1.json
  def update
    respond_to do |format|
      if @agency_user.update(agency_user_params)
        format.html { redirect_to @agency_user, notice: 'Agency user was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @agency_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def confirm_delete
  end

  # DELETE /agency_users/1
  # DELETE /agency_users/1.json
  def destroy
    @agency_user.destroy
    respond_to do |format|
      format.html { redirect_to agency_users_url, notice: 'Agency user was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_agency_user
      @agency_user = AgencyUser.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def agency_user_params
      params.require(:agency_user).permit(:email, :password)
    end

    def require_admin_request!
      if !is_admin_request? && !is_local_request?
        renderAccessDenied
      end
    end

end

