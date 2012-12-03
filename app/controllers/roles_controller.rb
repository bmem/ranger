class RolesController < ApplicationController
  skip_load_and_authorize_resource

  def index
    load_users
    @roles = ActiveSupport::OrderedHash.new
    Role::ALL.each do |r|
      @roles[r] = select_user_ids r
    end

    respond_to do |format|
      format.html
      format.json { render :json => @roles }
    end
  end

  def show
    if Role.valid? params[:id]
      load_role(params[:id])
      load_users

      respond_to do |format|
        format.html { render :template => 'roles/show_role' }
        format.json { render :json => @user_ids }
      end
    else
      @user = User.find params[:id]
      respond_to do |format|
        format.html { render :template => "roles/show_user" }
        format.json { render :json => @user.roles }
      end
    end
  end

  def update
    if Role.valid? params[:id]
      update_role
    else
      update_user
    end
  end

  private
  def update_role
    @role = params[:id]
    UserRole.transaction do
      new_ids = (params[:users] || []).map(&:to_i)
      to_delete = UserRole.where(:role => @role)
      unless new_ids.empty?
        to_delete = to_delete.where("user_id NOT IN (?)", new_ids)
      end
      to_delete.destroy_all
      new_ids.each {|id| UserRole.create!(:role => @role, :user_id => id)}
    end
    respond_to do |format|
      format.html { redirect_to :back,
        :notice => 'Role was successfully updated' }
      format.json { head :no_content }
    end
  end

  def update_user
    @user = User.find params[:id]
    new_roles = (params[:roles] || []).map &:to_sym
    User.transaction do
      to_add = new_roles - @user.roles.map(&:to_sym)
      @user.user_roles.each do |ur|
        ur.delete unless ur.role.to_sym.in? new_roles
      end
      to_add.each do |role|
        @user.user_roles.build(:role => role)
      end

      if @user.save
        respond_to do |format|
          flash[:notice] = 'User was updated successfully'
          format.html { redirect_to :action => 'show', :id => @user.id }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          flash[:notice] = "invalid roles"
          format.html { render :template => "roles/show_user" }
          format.json { render :json => @user.errors,
            :status => :unprocessable_entity }
        end
      end
    end
  end

  def load_role(role)
    @role = Role[role]
    @page_title ||= @role.name
    @user_ids = select_user_ids @role
  end

  def select_user_ids(role)
    UserRole.where(:role => role.to_sym).map(&:user_id).to_set
  end

  def load_users
    @users = User.order(:email)
  end
end
