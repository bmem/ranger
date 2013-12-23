class AssetUsesController < EventBasedController
  load_and_authorize_resource

  # GET /asset_uses
  # GET /asset_uses.json
  def index
    @asset_uses = @asset_uses.where(event_id: @event.id).includes(:event)
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

  # GET /asset_uses/new
  # GET /asset_uses/new.json
  def new
    @asset_use.event = @event
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
    @asset_use.event = @event
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
      if @asset_use.update_attributes(params[:asset_use])
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
    @asset_use = AssetUse.find(params[:id])
    @asset_use.destroy

    respond_to do |format|
      format.html { redirect_to event_asset_uses_url(@event) }
      format.json { head :no_content }
    end
  end

  def subject_record
    @asset_use
  end

  def default_sort_column
    'checked_out'
  end

  def default_sort_column_direction
    'desc'
  end
end
