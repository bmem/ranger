class AssetsController < EventBasedController
  load_and_authorize_resource

  # GET /assets
  # GET /assets.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @assets }
    end
  end

  # GET /assets/1
  # GET /assets/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @asset }
    end
  end

  # GET /assets/new
  # GET /assets/new.json
  def new
    params[:type].try do |type|
      # Create Asset of the right type so view can use instance methods
      @asset = type.constantize.new
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
      if @asset.update_attributes(params[:asset])
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
end
