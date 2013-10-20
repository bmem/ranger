class ProfilesController < ApplicationController
  load_and_authorize_resource

  # GET /profiles
  # GET /profiles.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @profiles }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @profile }
    end
  end

  # GET /profiles/1/edit
  def edit
  end

  # PUT /profiles/1
  # PUT /profiles/1.json
  def update
    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        format.html { redirect_to @profile.person, notice: 'Profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def subject_record
    @profile
  end
end
