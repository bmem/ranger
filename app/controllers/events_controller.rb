class EventsController < EventBasedController
  # GET /events
  # GET /events.json
  def index
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

  # GET /events/new
  # GET /events/new.json
  def new
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
      if @event.update_attributes(params[:event])
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

  def subject_record
    @event
  end
end
