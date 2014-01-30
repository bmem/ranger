class ProfilesController < ApplicationController
  after_filter :verify_authorized, except: :index
  after_filter :verify_policy_scoped, only: :index

  # GET /profiles
  # GET /profiles.json
  def index
    @profiles = policy_scope(Profile).includes(:person)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @profiles }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
    @profile = Profile.find(params[:id])
    authorize @profile
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @profile }
    end
  end

  # GET /profiles/1/edit
  def edit
    @profile = Profile.find(params[:id])
    authorize @profile
  end

  # PUT /profiles/1
  # PUT /profiles/1.json
  def update
    @profile = Profile.find(params[:id])
    authorize @profile
    respond_to do |format|
      if @profile.update_attributes(profile_params)
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

  private
  def profile_params
    params.require(:profile).
      permit(*policy(@profile).permitted_attributes)
  end
end
