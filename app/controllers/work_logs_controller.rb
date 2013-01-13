class WorkLogsController < EventBasedController
  # GET /work_logs
  # GET /work_logs.json
  def index
    ex = select_options
    @work_logs = @work_logs.where(:event_id => @event.id) if @event
    @work_logs = @work_logs.where(:shift_id => ex.shift) if ex.shift
    @work_logs = @work_logs.where(:involvement_id => ex.involvement) if ex.involvement
    @work_logs = @work_logs.where(:position_id => ex.position) if ex.position
    @work_logs = @work_logs.order('start_time DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @work_logs }
    end
  end

  # GET /work_logs/1
  # GET /work_logs/1.json
  def show
    @event = @work_log.event
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @work_log }
    end
  end

  # GET /work_logs/new
  # GET /work_logs/new.json
  def new
    select_options(@work_log)
    @work_log.start_time = DateTime.now

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @work_log }
    end
  end

  # GET /work_logs/1/edit
  def edit
    select_options(@work_log)
  end

  # POST /work_logs
  # POST /work_logs.json
  def create
    respond_to do |format|
      if @work_log.save
        format.html { redirect_to @work_log, :notice => 'Work log was successfully created.' }
        format.json { render :json => @work_log, :status => :created, :location => @work_log }
      else
        format.html do
          select_options(@work_log)
          render :action => "new"
        end
        format.json { render :json => @work_log.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /work_logs/1
  # PUT /work_logs/1.json
  def update
    respond_to do |format|
      if @work_log.update_attributes(params[:work_log])
        format.html { redirect_to @work_log, :notice => 'Work log was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @work_log.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /work_logs/1
  # DELETE /work_logs/1.json
  def destroy
    @work_log.destroy

    respond_to do |format|
      format.html { redirect_to work_logs_url }
      format.json { head :no_content }
    end
  end

  def subject_record
    @work_log
  end

  private
  def select_options(work = WorkLog.new)
    if params[:position_id].present?
      work.position ||= Position.find(params[:position_id])
    elsif params[:slot_id].present?
      slot ||= Slot.find(params[:slot_id]).position
      work.position ||= slot.position if slot
    end
    if params[:shift_id]
      work.shift ||= Shift.find(params[:shift_id])
    elsif slot
      work.shift ||= slot.shift
    end
    work.involvement ||= readable(Involvement.find(params[:involvement_id])) if params[:involvement_id]
    @event ||= work.shift.event if work.shift
    work.event ||= @event
    @positions = @involvement ? @involvement.positions : readable(Position).order(:name)
    @involvements = @involvement ? [@involvement] : readable(Involvement).order(:name)
    @shifts = work.shift ? [work.shift] :
      @event ? @event.shifts : readable(Shift).order(:start_time)
    @events = @event ? [@event] : readable(Event).order('end_date DESC')
    work
  end

  def readable(query)
    query.accessible_by(current_ability)
  end
end
