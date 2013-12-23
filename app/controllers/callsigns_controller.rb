class CallsignsController < ApplicationController
  load_and_authorize_resource

  # GET /callsigns
  # GET /callsigns.json
  def index
    @callsigns = order_by_params(@callsigns).page(params[:page]).
      includes(:assignments)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @callsigns }
    end
  end

  # GET /callsigns/1
  # GET /callsigns/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @callsign }
    end
  end

  # GET /callsigns/new
  # GET /callsigns/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @callsign }
    end
  end

  # GET /callsigns/1/edit
  def edit
  end

  # POST /callsigns
  # POST /callsigns.json
  def create
    respond_to do |format|
      if @callsign.save
        format.html { redirect_to @callsign, notice: 'Callsign was successfully created.' }
        format.json { render json: @callsign, status: :created, location: @callsign }
      else
        format.html { render action: "new" }
        format.json { render json: @callsign.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /callsigns/1
  # PUT /callsigns/1.json
  def update
    respond_to do |format|
      if @callsign.update_attributes(params[:callsign])
        format.html { redirect_to @callsign, notice: 'Callsign was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @callsign.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /callsigns/1
  # DELETE /callsigns/1.json
  def destroy
    @callsign.destroy

    respond_to do |format|
      format.html { redirect_to callsigns_url }
      format.json { head :no_content }
    end
  end

  def subject_record
    @callsign
  end

  def default_sort_column
    'name'
  end
end
