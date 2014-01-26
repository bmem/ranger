class UsersController < ApplicationController
  after_filter :verify_authorized, except: :index
  after_filter :verify_policy_scoped, only: :index

  # GET /users
  # GET /users.json
  def index
    @users = policy_scope(User)
    @users = @users.includes(:person)
    @users = order_by_params(@users).
      paginate(:page => params[:page], :per_page => params[:page_size] || 100)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @users }
    end
  end

  # GET /people/1
  # GET /people/1.json
  def show
    @user = User.find(params[:id])
    authorize @user
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @user }
    end
  end

  # GET /people/new
  # GET /people/new.json
  def new
    @user = User.find(params[:id])
    authorize @user
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @user }
    end
  end

  # GET /people/1/edit
  def edit
    @user = User.find(params[:id])
    authorize @user
  end

  # No create through this controller

  # PUT /people/1
  # PUT /people/1.json
  def update
    @user = User.find(params[:id])
    authorize @user
    respond_to do |format|
      if @user.update_attributes(user_attributes)
        target = @user.person || @user
        format.html { redirect_to target, :notice => 'User was successfully updated.' }
        format.json { head :no_content }
      else
        if can? :edit, @user
          format.html { render :action => "edit" }
        else
          format.html { redirect_to @user.person, :notice => @user.errors.full_messages.join(', ') }
        end
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @user = User.find(params[:id])
    authorize @user
    @user.destroy

    respond_to do |format|
      format.html { redirect_to people_url }
      format.json { head :no_content }
    end
  end

  def subject_record
    @user
  end

  def default_sort_column
    'people.display_name'
  end

  private
  def user_attributes
    params.require(:user).permit(*policy(@user).permitted_attributes)
  end
end
