class WorkLogsController < EventBasedController
  after_filter :verify_authorized, except: :index
  after_filter :verify_policy_scoped, only: :index

  # GET /work_logs
  # GET /work_logs.json
  def index
    @param_prototype = p = select_options
    @work_logs = policy_scope(WorkLog)
    @work_logs = @work_logs.where(:event_id => @event.id) if @event
    @work_logs = @work_logs.where(:shift_id => p.shift) if p.shift
    @work_logs = @work_logs.where(:involvement_id => p.involvement) if p.involvement
    @work_logs = @work_logs.where(:position_id => p.position) if p.position
    # sort with outstanding work logs (end time null) first
    @work_logs = @work_logs.order('end_time IS NOT NULL, end_time DESC, start_time DESC')
    @work_logs = @work_logs.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @work_logs }
    end
  end

  # GET /work_logs/1
  # GET /work_logs/1.json
  def show
    authorize @work_log
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @work_log }
    end
  end

  # GET /work_logs/1/changes
  # GET /work_logs/1/changes.json
  def changes
    authorize @work_log
    @audits = order_by_params @work_log.audits, default_sort_column: 'version', default_sort_column_direction: 'desc'
    respond_to do |format|
      format.html # changes.html.haml
      format.json { render json: @audits }
    end
  end

  # GET /work_logs/new
  # GET /work_logs/new.json
  def new
    @work_log = select_options
    authorize @work_log
    @work_log.start_time = Time.zone.now

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @work_log }
    end
  end

  # GET /work_logs/1/edit
  def edit
    authorize @work_log
    select_options(@work_log)
  end

  # POST /work_logs
  # POST /work_logs.json
  def create
    @work_log = select_options
    @work_log.attributes = work_log_params
    authorize @work_log
    respond_to do |format|
      if @work_log.save
        format.html { redirect_to [@work_log.event, @work_log], notice: 'Work log was successfully created.' }
        format.json { render :json => @work_log, :status => :created, :location => @work_log }
      else
        format.html { render :action => "new" }
        format.json { render :json => @work_log.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /work_logs/1
  # PUT /work_logs/1.json
  def update
    authorize @work_log
    respond_to do |format|
      if @work_log.update_attributes(work_log_params)
        format.html { redirect_to [@work_log.event, @work_log], :notice => 'Work log was successfully updated.' }
        format.json { head :no_content }
      else
        select_options(@work_log)
        format.html { render :action => "edit" }
        format.json { render :json => @work_log.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /work_logs/1
  # DELETE /work_logs/1.json
  def destroy
    authorize @work_log
    @work_log.destroy

    respond_to do |format|
      format.html { redirect_to event_work_logs_url(@work_log.event) }
      format.json { head :no_content }
    end
  end

  def subject_record
    @work_log
  end

  def load_subject_record_by_id
    @work_log = WorkLog.find(params[:id])
  end

  private
  def work_log_params
    params.require(:work_log).
      permit(*policy(@work_log || WorkLog).permitted_attributes)
  end

  def select_options(work = WorkLog.new)
    if params[:slot_id].present?
      slot = Slot.find(params[:slot_id])
    end
    if params[:position_id].present?
      work.position ||= Position.find(params[:position_id])
    elsif slot
      work.position ||= slot.position
    end
    if params[:shift_id]
      work.shift ||= Shift.find(params[:shift_id])
    elsif slot
      work.shift ||= slot.shift
    end
    if params[:sign_out].present? && params[:sign_out]
      work.end_time = Time.zone.now
    end
    work.involvement ||= Involvement.find(params[:involvement_id]) if params[:involvement_id]
    @involvement = work.involvement
    @event ||= work.shift.event if work.shift
    work.event ||= @event
    @positions = @involvement ? @involvement.positions : policy_scope(Position)
    @involvements = if @involvement
        [@involvement]
      elsif @event
        policy_scope(@event.involvements).order(:name)
      else
        policy_scope(Involvement).order(:name)
      end
    if @event
      @shifts = @event.shifts.with_positions(work.position_id.presence || @positions)
    else
      @shifts = work.shift ? [work.shift] : []
    end
    @events = @event ? [@event] : policy_scope(Event).order('end_date DESC')
    work
  end
end
