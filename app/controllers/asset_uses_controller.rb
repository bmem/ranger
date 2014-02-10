class AssetUsesController < EventBasedController
  # GET /asset_uses
  # GET /asset_uses.json
  def index
    @asset_uses = policy_scope(@event.asset_uses)
    @asset_uses = @asset_uses.currently_out if params[:out].present?
    @asset_uses = @asset_uses.includes(:asset).includes(:involvement)
    @asset_uses = order_by_params @asset_uses
    @asset_uses = @asset_uses.page(params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @asset_uses }
    end
  end

  # GET /asset_uses/1
  # GET /asset_uses/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @asset_use }
    end
  end

  # GET /asset_uses/1/changes
  # GET /asset_uses/1/changes.json
  def changes
    @audits = order_by_params @asset_use.audits, default_sort_column: 'version', default_sort_column_direction: 'desc'
    respond_to do |format|
      format.html # changes.html.haml
      format.json { render json: @audits }
    end
  end

  # GET /asset_uses/new
  # GET /asset_uses/new.json
  def new
    @asset_use = @event.asset_uses.build
    @asset_use.attributes = asset_use_params if params[:asset_use].present?
    authorize @asset_use
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @asset_use }
    end
  end

  # GET /asset_uses/1/edit
  def edit
  end

  # POST /asset_uses
  # POST /asset_uses.json
  def create
    @asset_use = @event.asset_uses.build(asset_use_params)
    authorize @asset_use
    respond_to do |format|
      if @asset_use.save
        format.html { redirect_to [@event, @asset_use], notice: 'Asset use was successfully created.' }
        format.json { render json: @asset_use, status: :created, location: @asset_use }
      else
        format.html { render action: "new" }
        format.json { render json: @asset_use.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /asset_uses/1
  # PUT /asset_uses/1.json
  def update
    respond_to do |format|
      if @asset_use.update_attributes(asset_use_params)
        format.html { redirect_to [@event, @asset_use], notice: 'Asset use was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @asset_use.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /asset_uses/1
  # DELETE /asset_uses/1.json
  def destroy
    @asset_use.destroy

    respond_to do |format|
      format.html { redirect_to event_asset_uses_url(@event) }
      format.json { head :no_content }
    end
  end

  def subject_record
    @asset_use
  end

  def load_subject_record_by_id
    @asset_use = AssetUse.find(params[:id])
  end

  def default_sort_column
    'checked_out'
  end

  def default_sort_column_direction
    'desc'
  end

  private
  def asset_use_params
    params.require(:asset_use).
      permit(*policy(@asset_use || AssetUse.new).permitted_attributes)
  end
end
