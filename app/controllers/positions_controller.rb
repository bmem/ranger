class PositionsController < ApplicationController
  before_filter :authenticate_user!
  # TODO move this filter to ApplicationController after all Cancan expunged
  before_filter :load_subject_record_by_id, if: proc {|c| c.params[:id].present?}
  after_filter :verify_authorized, except: :index
  after_filter :verify_policy_scoped, only: :index

  # GET /positions
  # GET /positions.json
  def index
    @positions = policy_scope(Position)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @positions }
    end
  end

  # GET /positions/1
  # GET /positions/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @position }
    end
  end

  # GET /positions/1
  # GET /positions/1.json
  def changes
    respond_to do |format|
      format.html # changes.html.erb
      format.json { render :json => @position.audits }
    end
  end

  # GET /positions/new
  # GET /positions/new.json
  def new
    @position = Position.new
    authorize @position
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @position }
    end
  end

  # GET /positions/1/edit
  def edit
  end

  # POST /positions
  # POST /positions.json
  def create
    @position = Position.new position_params
    authorize @position
    respond_to do |format|
      if @position.save
        format.html { redirect_to @position, :notice => 'Position was successfully created.' }
        format.json { render :json => @position, :status => :created, :location => @position }
      else
        format.html { render :action => "new" }
        format.json { render :json => @position.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /positions/1
  # PUT /positions/1.json
  def update
    respond_to do |format|
      if @position.update_attributes(position_params)
        format.html { redirect_to @position, :notice => 'Position was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @position.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /positions/1
  # DELETE /positions/1.json
  def destroy
    @position.destroy

    respond_to do |format|
      format.html { redirect_to positions_url }
      format.json { head :no_content }
    end
  end

  # GET /positions/1/people
  # GET /positions/1/people.json
  def people
    @people = policy_scope(@position.people).page(params[:page])
    respond_to do |format|
      format.html # people.html.haml
      format.json { render :json => @people }
    end
  end

  def subject_record
    @position
  end

  def load_subject_record_by_id
    @position = Position.find(params[:id])
    authorize @position
  end

  private
  def position_params
    params.require(:position).
      permit(*policy(@position || Position).permitted_attributes)
  end
end
