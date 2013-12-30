class PositionsController < ApplicationController
  load_and_authorize_resource

  # GET /positions
  # GET /positions.json
  def index
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
    @position = Position.find(params[:id])
    authorize! :audit, @position
    respond_to do |format|
      format.html # changes.html.erb
      format.json { render :json => @position.audits }
    end
  end

  # GET /positions/new
  # GET /positions/new.json
  def new
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
      if @position.update_attributes(params[:position])
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
    @people = @position.people.accessible_by(current_ability).page(params[:page])
    respond_to do |format|
      format.html # people.html.haml
      format.json { render :json => @people }
    end
  end

  def subject_record
    @position
  end
end
