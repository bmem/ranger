class UserRolesController < ApplicationController
  # GET /user_roles
  # GET /user_roles.json
  # Shows users associated with each (or a specific) role.
  def index
    @user_roles = UserRole.accessible_by(current_ability)
    params[:role].try {|r| @user_roles = @user_roles.where(:role => r)}

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_roles }
    end
  end

  # GET /user_roles/1
  # GET /user_roles/1.json
  # Shows the roles for a user.
  def show
    @user = User.find(params[:id])
    authorize! :show, @user
    @user_roles = UserRole.where(:user_id => @user)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_roles }
    end
  end

  # GET /user_roles/1/edit
  # Show a form to choose a user's roles.
  def edit
    @user = User.find(params[:id])
    authorize! :show, @user
    @user_roles = UserRole.where(:user_id => @user)
  end

  # POST /user_roles
  # POST /user_roles.json
  # Add a user to a role.
  def create
    @user_role = UserRole.new(params[:user_role])
    @user = User.find(@user_role.user_id)
    authorize! :create, @user_role
    authorize! :show, @user
    respond_to do |format|
      if @user_role.save
        format.html { redirect_to user_role_path(@user.id), notice: 'User role was successfully created.' }
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
    @user = @user_role.user
    authorize! :show, @user
    authorize! :destroy, @user_role
    @user_role.destroy
    respond_to do |format|
      format.html { redirect_to user_role_path(@user.id), notice: 'User role was successfully created.' }
      format.json { head :no_content }
    end
  end

  def subject_record
    @user
  end
end
