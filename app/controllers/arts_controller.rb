class ArtsController < ApplicationController
  before_filter :load_subject_record_by_id, except: [:index, :new, :create]
  after_filter :verify_authorized, except: :index
  after_filter :verify_policy_scoped, only: :index

  # GET /arts
  # GET /arts.json
  def index
    @arts = policy_scope(Art)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @arts }
    end
  end

  # GET /arts/1
  # GET /arts/1.json
  def show
    authorize @art
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @art }
    end
  end

  # GET /arts/1/changes
  # GET /arts/1/changes.json
  def changes
    authorize @art
    @audits = order_by_params @art.audits,
      default_sort_column: 'version', default_sort_column_direction: 'desc'
    respond_to do |format|
      format.html # changes.html.erb
      format.json { render :json => @slot_template.audits }
    end
  end

  # GET /arts/new
  # GET /arts/new.json
  def new
    @art = Art.new
    authorize @art
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @art }
    end
  end

  # GET /arts/1/edit
  def edit
    authorize @art
  end

  # POST /arts
  # POST /arts.json
  def create
    @art = Art.new art_params
    authorize @art
    respond_to do |format|
      if @art.save
        format.html { redirect_to @art, notice: 'Art was successfully created.' }
        format.json { render json: @art, status: :created, location: @art }
      else
        format.html { render action: "new" }
        format.json { render json: @art.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /arts/1
  # PUT /arts/1.json
  def update
    authorize @art
    respond_to do |format|
      if @art.update_attributes(art_params)
        format.html { redirect_to @art, notice: 'Art was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @art.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /arts/1
  # DELETE /arts/1.json
  def destroy
    authorize @art
    @art.destroy

    respond_to do |format|
      format.html { redirect_to arts_url }
      format.json { head :no_content }
    end
  end

  def subject_record
    @art
  end

  protected
  def load_subject_record_by_id
    @art = Art.find(params[:id])
  end

  private
  def art_params
    params.require(:art).
      permit(*policy(@art || Art.new).permitted_attributes)
  end
end
