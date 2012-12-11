class EventsController < EventBasedController
  # GET /events
  # GET /events.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @events }
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

  # GET /events/1/report_hours_credits
  # GET /events/1/report_hours_credits.csv
  def report_hours_credits
    @event = Event.find(params[:event_id])
    participants = @event.participants.order(:name)
    # TODO don't hard-code perimeters
    perim_ids = @event.credit_schemes.where(:name => 'Perimeters').first.position_ids
    pre_start = @event.start_date.to_time_in_current_zone
    # TODO don't hard code dates
    evt_start = Time.zone.local(2012, 8, 26, 18, 0)
    evt_end = Time.zone.local(2012, 9, 4, 0, 0)
    post_end = @event.end_date.to_time_in_current_zone
    @title = 'Total Hours and Credits'
    @cols = [
      'Name',
      'Status',
      'Total Hours',
      'Total Credits',
      'Pre-Event Hours',
      'Pre-Event Credits',
      'Event Hours',
      'Event Credits',
      'Post-Event Hours',
      'Post-Event Credits',
      'Perimeter Hours',
      'Perimeter Credits'
    ]
    @rows = participants.map do |p|
      total_h = to_h(p.total_seconds)
      total_c = p.total_credits_formatted
      pre_h = to_h(p.total_seconds(pre_start, evt_start))
      pre_c = p.total_credits_formatted(pre_start, evt_start)
      evt_h = to_h(p.total_seconds(evt_start, evt_end))
      evt_c = p.total_credits_formatted(evt_start, evt_end)
      post_h = to_h(p.total_seconds(evt_end, post_end))
      post_c = p.total_credits_formatted(evt_end, post_end)
      perim_sec = 0
      perim_c = 0.0
      p.work_logs.find_all {|w| w.position_id.in? perim_ids}.each do |w|
        perim_sec += w.duration_seconds
        perim_c += w.credit_value
      end
      perim_h = to_h(perim_sec)
      perim_c = format('%.2f', perim_c)
      [
        p.name, p.personnel_status,
        total_h, total_c,
        pre_h, pre_c,
        evt_h, evt_c,
        post_h, post_c,
        perim_h, perim_c
      ]
    end

    respond_to do |format|
      format.html { render :action => 'report' }
      format.csv { render :action => 'report', :format => false }
    end
  end

  def subject_record
    @event
  end

  private
  def to_h(secs)
    format('%.2f', secs.to_f / 1.hour)
  end
end
