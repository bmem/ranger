class UsersController < ApplicationController
  load_and_authorize_resource :except => :index

  # GET /users
  # GET /users.json
  def index
    @users = User.accessible_by(current_ability).includes(:person).order('people.callsign').
      paginate(:page => params[:page], :per_page => params[:page_size] || 100)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @users }
    end
  end

  # GET /people/1
  # GET /people/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @user }
    end
  end

  # GET /people/new
  # GET /people/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @user }
    end
  end

  # GET /people/1/edit
  def edit
  end

  # No create through this controller

  # PUT /people/1
  # PUT /people/1.json
  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, :notice => 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to people_url }
      format.json { head :no_content }
    end
  end

  def subject_record
    @user
  end
end
