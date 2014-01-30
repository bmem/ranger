class CallsignsController < ApplicationController
  after_filter :verify_authorized, except: :index
  after_filter :verify_policy_scoped, only: :index

  # GET /callsigns
  # GET /callsigns.json
  def index
    @callsigns = policy_scope(Callsign)
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
    @callsign = Callsign.find(params[:id])
    authorize @callsign
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @callsign }
    end
  end

  # GET /callsigns/1
  # GET /callsigns/1.json
  def changes
    @callsign = Callsign.find(params[:id])
    authorize @callsign
    respond_to do |format|
      format.html # changes.html.erb
      format.json { render :json => @callsign.audits }
    end
  end

  # GET /callsigns/new
  # GET /callsigns/new.json
  def new
    @callsign = Callsign.new status: 'pending'
    authorize @callsign
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @callsign }
    end
  end

  # GET /callsigns/1/edit
  def edit
    @callsign = Callsign.find(params[:id])
    authorize @callsign
  end

  # POST /callsigns
  # POST /callsigns.json
  def create
    @callsign = Callsign.new callsign_params
    authorize @callsign
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
    @callsign = Callsign.find(params[:id])
    authorize @callsign
    respond_to do |format|
      if @callsign.update_attributes(callsign_params)
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
    @callsign = Callsign.find(params[:id])
    authorize @callsign
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

  private
  def callsign_params
    params.require(:callsign).
      permit(*policy(@callsign || Callsign).permitted_attributes)
  end
end
