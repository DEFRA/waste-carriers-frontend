#Controller for resource-oriented CRUD operations on agency users (a.k.a. internal users) 

class AgencyUsersController < ApplicationController

  before_filter :require_admin_request!


  #Only administrators can manage other users - requires administrator login.
  before_filter :authenticate_admin!

  before_action :set_agency_user, only: [:show, :edit, :update, :confirm_delete, :destroy]

  # GET /agency_users
  # GET /agency_users.json
  def index
    @agency_users = AgencyUser.all.sort_by(&:email)
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
        addRemoveRoles
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
      logger.info 'GET HERE'+agency_user_params.to_s
      
      if @agency_user.update(agency_user_params)
        addRemoveRoles
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
    addRemoveRoles
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
      if !@agency_user 
        renderNotFound
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def agency_user_params
      params.require(:agency_user).permit(:email, :password, :admin, :financeBasic)
    end

    def require_admin_request!
      if Rails.application.config.require_admin_requests
        if !is_admin_request? && !is_local_request?
          #renderAccessDenied
          renderNotFound
        end
      end
    end
    
    # This functions adds or removes the roles from the user
    def addRemoveRoles
      # This list of roles should match that in the role.rb ROLE_TYPES list
      addRemoveRole(:Role_admin)
      addRemoveRole(:Role_financeBasic)
      addRemoveRole(:Role_financeAdmin)
      addRemoveRole(:Role_ncccRefund)
    end
    
    # Adds or removes a role from a user
    def addRemoveRole(role)
      if params[role] == '1'
        @agency_user.add_role role, AgencyUser
      else
        @agency_user.remove_role role, AgencyUser
      end
    end

end

