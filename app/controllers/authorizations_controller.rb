class AuthorizationsController < EventBasedController
  # GET /authorizations
  # GET /authorizations.json
  def index
    @authorizations = policy_scope(@event.authorizations)
    params[:type].presence.try do |type|
      @authorizations = @authorizations.where(type: type)
    end
    params[:involvement_id].presence.try do |iid|
      @authorizations = @authorizations.where(involvement_id: iid)
    end
    @authorizations = @authorizations.includes(:involvement).includes(:user)
    @authorizations = order_by_params(@authorizations)
    @authorizations = @authorizations.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @authorizations }
    end
  end

  # GET /authorizations/1
  # GET /authorizations/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @authorization }
    end
  end

  # GET /authorizations/new
  # GET /authorizations/new.json
  def new
    @authorization = @event.authorizations.build
    @authorization.type = params[:type]
    @authorization.involvement_id = params[:involvement_id]
    authorize @authorization

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @authorization }
    end
  end

  # GET /authorizations/1/edit
  def edit
  end

  # POST /authorizations
  # POST /authorizations.json
  def create
    @authorization = @event.authorizations.build(authorization_params)
    @authorization.user_id = current_user.id
    @authorization.becomes @authorization.type.constantize
    authorize @authorization

    respond_to do |format|
      if @authorization.save
        format.html { redirect_to @authorization, notice: 'Authorization was successfully created.' }
        format.json { render json: @authorization, status: :created, location: @authorization }
      else
        format.html { render action: "new" }
        format.json { render json: @authorization.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /authorizations/1
  # PATCH/PUT /authorizations/1.json
  def update
    respond_to do |format|
      if @authorization.update_attributes(authorization_params)
        format.html { redirect_to @authorization, notice: 'Authorization was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @authorization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authorizations/1
  # DELETE /authorizations/1.json
  def destroy
    @authorization.destroy

    respond_to do |format|
      format.html { redirect_to event_authorizations_url(@event) }
      format.json { head :no_content }
    end
  end

  def subject_record
    @authorization
  end

  def load_subject_record_by_id
    @authorization = @event.authorizations.find(params[:id])
  end

  def default_sort_column
    'involvements.name'
  end

  private
    def authorization_params
      params.require(:authorization).
        permit(*policy(@authorization || Authorization.new).permitted_attributes)
    end
end
