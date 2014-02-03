class EventsController < EventBasedController
  after_filter :verify_authorized, except: [:index, :set_default]
  after_filter :verify_policy_scoped, only: :index

  # GET /events
  # GET /events.json
  def index
    @events = policy_scope(Event)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @events }
    end
  end

  # POST /events/set_default?default_event_id=1
  def set_default
    respond_to do |format|
      if params[:default_event_id].present?
        @event = Event.find(params[:default_event_id])
        session[:default_event_id] = @event.id
        format.html { redirect_to @event }
        format.json { head :no_content }
      else
        @event = nil
        session[:default_event_id] = nil
        format.html { redirect_to events_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @event }
    end
  end

  # GET /events/1/changes
  # GET /events/1/changes.json
  def changes
    @audits = order_by_params @event.audits, default_sort_column: 'version', default_sort_column_direction: 'desc'
    respond_to do |format|
      format.html # changes.html.haml
      format.json { render json: @audits }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new
    authorize @event
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @event }
    end
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new event_params
    authorize @event
    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, :notice => 'Event was successfully created.' }
        format.json { render :json => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.json { render :json => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update_attributes(event_params)
        format.html { redirect_to @event, :notice => 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end

  def load_subject_record_by_id
    @event = Event.find(params[:id])
  end

  def subject_record
    @event
  end

  private
  def event_params
    params.require(:event).
      permit(*policy(@event || Event).permitted_attributes)
  end
end
