class TeamsController < ApplicationController
  before_filter :authenticate_user!
  # TODO move this filter to ApplicationController after all Cancan expunged
  before_filter :load_subject_record_by_id, if: proc {|c| c.params[:id].present?}
  after_filter :verify_authorized, except: :index
  after_filter :verify_policy_scoped, only: :index

  # GET /teams
  # GET /teams.json
  def index
    @teams = policy_scope(Team)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @teams }
    end
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @team }
    end
  end

  # GET /teams/1
  # GET /teams/1.json
  def changes
    respond_to do |format|
      format.html # changes.html.erb
      format.json { render :json => @team.audits }
    end
  end

  # GET /teams/new
  # GET /teams/new.json
  def new
    @team = Team.new
    authorize @team
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @team }
    end
  end

  # GET /teams/1/edit
  def edit
  end

  # POST /teams
  # POST /teams.json
  def create
    @team = Team.new team_params
    authorize @team
    respond_to do |format|
      if @team.save
        format.html { redirect_to @team, notice: 'Team was successfully created.' }
        format.json { render json: @team, status: :created, location: @team }
      else
        format.html { render action: "new" }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /teams/1
  # PUT /teams/1.json
  def update
    respond_to do |format|
      if @team.update_attributes(team_params)
        format.html { redirect_to @team, notice: 'Team was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.json
  def destroy
    @team.destroy

    respond_to do |format|
      format.html { redirect_to teams_url }
      format.json { head :no_content }
    end
  end

  def subject_record
    @team
  end

  def load_subject_record_by_id
    @team = Team.find(params[:id])
    authorize @team
  end

  private
  def team_params
    params.require(:team).
      permit(*policy(@team || Team).permitted_attributes)
  end
end
