#Controller for resource-oriented CRUD operations on agency users (a.k.a. internal users)

class AgencyUsersController < ApplicationController

  before_action :require_admin_request!


  #Only administrators can manage other users - requires administrator login.
  before_action :authenticate_admin!

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
        format.html { redirect_to @agency_user, notice: I18n.t('registrations.form.agencyUserCreated') }
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
        addRemoveRoles
        format.html { redirect_to @agency_user, notice: I18n.t('registrations.form.agencyUserUpdated') }
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
      format.html { redirect_to agency_users_url, notice: I18n.t('registrations.form.agencyUserDeleted') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_agency_user
      @agency_user = AgencyUser.find(params[:id])
      if !@agency_user
        render_not_found
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def agency_user_params
      params.require(:agency_user).permit(:email, :password, :admin, :financeBasic)
    end

    def require_admin_request!
      if Rails.application.config.require_admin_requests
        if !is_admin_request? && !is_local_request?
          render_not_found
        end
      end
    end

    # This functions adds or removes the roles from the user
    def addRemoveRoles
      isFinanceSuper = current_admin.has_role? :Role_financeSuper, Admin
      if isFinanceSuper
        if params[:userRole]
          logger.debug 'use select list'
          # Use select list
          Role.roles.each do |role|
            if params[:userRole] == role
		      @agency_user.add_role role, AgencyUser
		    else
		      @agency_user.remove_role role, AgencyUser
		    end
          end
        else
          # Use checkbx list
          logger.debug 'use checkbox list'
          # This list of roles should match that in the role.rb ROLE_TYPES list
          addRemoveRole(:Role_financeBasic)
          addRemoveRole(:Role_financeAdmin)
          addRemoveRole(:Role_agencyRefundPayment)
        end
      end
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
