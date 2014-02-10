class UserRolesController < ApplicationController
  before_filter :load_and_authorize_user
  after_filter :verify_authorized, except: :index
  after_filter :verify_policy_scoped, only: :index

  # GET /user_roles
  # GET /user_roles.json
  # Shows users associated with each (or a specific) role.
  def index
    @user_roles = policy_scope(@user ? @user.user_roles : UserRole)
    @selected_roles = selected_array_param params[:role]
    @user_roles = @user_roles.where(role: @selected_roles) if @selected_roles.present?
    @user_roles = @user_roles.page(params[:page])

    respond_to do |format|
      format.html { render action: @user ? 'for_user' : 'index' }
      format.json { render json: @user_roles }
    end
  end

  # POST /user_roles
  # POST /user_roles.json
  # Add a user to a role.
  def create
    @user_role = @user ? @user.user_roles.build(user_role_params) : UserRole.new(user_role_params)
    authorize @user_role
    @user = User.find(@user_role.user_id)
    @user_role.audit_comment = "Grant #{@user_role.role} to #{@user}" if @user_role.audit_comment.blank?
    respond_to do |format|
      if @user_role.save
        format.html { redirect_to user_user_roles_path(@user.id), notice: "Granted #{@user_role.role_obj} to #{@user_role.user}" }
        format.json { render json: @user_role, status: :created, location: user_role_path(@user.id) }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_roles/1
  # DELETE /user_roles/1.json
  def destroy
    @user_role = UserRole.find(params[:id])
    authorize @user_role
    @user_role.audit_comment = "Revoke #{@user_role.role} from #{@user}" if @user_role.audit_comment.blank?
    @user_role.destroy
    respond_to do |format|
      format.html { redirect_to user_user_roles_path(@user_role.user), notice: "Revoked #{@user_role.role_obj} from #{@user_role.user}" }
      format.json { head :no_content }
    end
  end

  def subject_record
    @user
  end

  private
  def user_role_params
    params.require(:user_role).
      permit(*policy(@user_role || UserRole.new).permitted_attributes)
  end

  def load_and_authorize_user
    params[:user_id].presence.try do |uid|
      @user = User.find(params[:user_id])
      authorize @user, :show?
    end
  end
end
