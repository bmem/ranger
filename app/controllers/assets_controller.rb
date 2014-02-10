class AssetsController < EventBasedController
  helper_method :selected_types

  # GET /assets
  # GET /assets.json
  def index
    @assets = policy_scope(@event.assets)
    @assets = @assets.where(type: selected_types)
    if params[:sort_column].present?
      @assets = order_by_params @assets
    else
      @assets = @assets.order [:type, :name]
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @assets }
    end
  end

  # GET /assets/1
  # GET /assets/1.json
  def show
    @asset_uses = @asset.asset_uses.includes(:involvement)
    @asset_uses = order_by_params @asset_uses, default_sort_column: 'checked_out', default_sort_column_direction: 'desc'
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @asset }
    end
  end

  # GET /assets/1/changes
  # GET /assets/1/changes.json
  def changes
    @audits = order_by_params @asset.audits, default_sort_column: 'version', default_sort_column_direction: 'desc'
    respond_to do |format|
      format.html # changes.html.haml
      format.json { render json: @audits }
    end
  end

  # GET /assets/new
  # GET /assets/new.json
  def new
    @asset = @event.assets.build
    authorize @asset
    params[:type].try do |type|
      # Create Asset of the right type so view can use instance methods
      @asset = @asset.becomes(type.constantize)
      @asset.type = type
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @asset }
    end
  end

  # GET /assets/1/edit
  def edit
  end

  # POST /assets
  # POST /assets.json
  def create
    @asset = @event.assets.build
    @asset.attributes = asset_params
    # TODO consider a controller for each asset type, with their own reports
    @asset = @asset.becomes(@asset.type.constantize)
    authorize @asset
    respond_to do |format|
      if @asset.save
        format.html { redirect_to [@event, @asset], notice: 'Asset was successfully created.' }
        format.json { render json: @asset, status: :created, location: [@event, @asset] }
      else
        format.html { render action: "new" }
        format.json { render json: @asset.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /assets/1
  # PUT /assets/1.json
  def update
    respond_to do |format|
      if @asset.update_attributes(asset_params)
        format.html { redirect_to [@event, @asset], notice: 'Asset was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @asset.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assets/1
  # DELETE /assets/1.json
  def destroy
    @asset.destroy

    respond_to do |format|
      format.html { redirect_to event_assets_url(@event) }
      format.json { head :no_content }
    end
  end

  def subject_record
    @asset
  end

  def load_subject_record_by_id
    @asset = selected_type.find(params[:id])
    @asset.becomes @asset.type.constantize
    @asset
  end

  def default_sort_column
    'name'
  end

  private
  def asset_params
    params.require(:asset).
      permit(*policy(@asset || selected_type.new).permitted_attributes)
  end

  def selected_types
    selected_array_param(params[:asset_type]).presence ||
      params[:type_plural].presence.try {|t| t.to_s.singularize.capitalize} ||
      Asset::TYPES
  end

  def selected_type
    selected_types.size == 1 ? selected_types.first.constantize : Asset
  end
end
