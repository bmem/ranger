class ShiftsController < EventBasedController
  before_filter :load_and_authorize_involvement

  # GET /shifts
  # GET /shifts.json
  def index
    page = (params[:page] || 1).to_i
    @shifts = policy_scope(Shift)
    @shifts = @shifts.where(:event_id => @event.id) if @event
    selected_array_param(params[:position_id]).presence.try do |position_ids|
      @shifts = @shifts.with_positions(position_ids)
    end
    @shifts = order_by_params @shifts
    @shifts = @shifts.page(page)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @shifts, meta: {total_pages: @shifts.total_pages, page: page} }
    end
  end

  # GET /shifts/1
  # GET /shifts/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @shift }
    end
  end

  # GET /shifts/1/changes
  # GET /shifts/1/changes.json
  def changes
    @audits = order_by_params @shift.audits, default_sort_column: 'version', default_sort_column_direction: 'desc'
    respond_to do |format|
      format.html # changes.html.haml
      format.json { render json: @audits }
    end
  end

  # GET /shifts/new
  # GET /shifts/new.json
  def new
    if @event
      @shift = @event.shifts.build
      @shift.end_time = @shift.start_time = Time.zone.parse(@event.start_date.to_s)
    else
      @shift = Shift.new
    end
    authorize @shift
    if params[:date].present? and d = Time.zone.parse(params[:date])
      @shift.end_time = @shift.start_time = d
    end
    if params[:template].present? and t = ShiftTemplate.find(params[:template])
      @shift_template = t
      @shift.merge_from_template! t, params[:date]
    end
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @shift }
    end
  end

  # GET /shifts/1/edit
  def edit
  end

  # POST /shifts
  # POST /shifts.json
  def create
    @shift = @event ? @event.shifts.build : Shift.new
    @shift.attributes = shift_params
    authorize @shift
    respond_to do |format|
      if @shift.save
        if params[:template].present? and t = ShiftTemplate.find(params[:template])
          @shift_template = t
          @shift.create_slots_from_template t
        end
        format.html { redirect_to [@shift.event, @shift], :notice => 'Shift was successfully created.' }
        format.json { render :json => @shift, :status => :created, :location => @shift }
      else
        format.html { render :action => "new" }
        format.json { render :json => @shift.errors, :status => :unprocessable_entity }
      end
    end
  end

  # POST /shifts/1/copy
  def copy
    startday = Date.parse(params['start'])
    endday = Date.parse(params['end'])
    delta_t = @shift.end_time - @shift.start_time
    results = []
    failed = false
    respond_to do |format|
      @shift.transaction do
        (startday..endday).each do |day|
          if day != @shift.start_time.to_date
            c = Shift.new @shift.attributes
            c.start_time = date_and_time(day, @shift.start_time)
            c.end_time = c.start_time + delta_t
            unless c.save
              failed = true
              format.html { redirect_to [@shift.event, @shift], :alert => "Copy shift failed: #{c.errors.full_messages.to_sentence}" }
              format.json { render :json => c.errors, :status => :unprocessable_entity }
              raise ActiveRecord::Rollback
            end # unless c.save
            @shift.slots.each do |slot|
              unless c.slots.create(slot.attributes)
                failed = true
                format.html { redirect_to [@shift.event, @shift], :alert => "Copy shift failed: #{c.slots.last.errors.full_messages.to_sentence}" }
                format.json { render :json => c.errors, :status => :unprocessable_entity }
                raise ActiveRecord::Rollback
              end # c.slots.create
            end # slots.each
            results << c
          end # if day
        end # days.each
      end # shift.transaction
      unless failed
        format.html { redirect_to event_shifts_path(@shift.event), :notice => "Shift was copied #{results.count} times" }
        format.json { render :json => results, :status => :created }
      end # unless failed
    end # respond_to
  end # copy

  # PUT /shifts/1
  # PUT /shifts/1.json
  def update
    respond_to do |format|
      if @shift.update_attributes(shift_params)
        format.html { redirect_to [@shift.event, @shift], :notice => 'Shift was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @shift.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shifts/1
  # DELETE /shifts/1.json
  def destroy
    @shift.destroy

    respond_to do |format|
      format.html { redirect_to event_shifts_url(@event) }
      format.json { head :no_content }
    end
  end

  def subject_record
    @shift
  end

  def load_subject_record_by_id
    @shift = Shift.find(params[:id])
  end

  def default_sort_column
    'start_time'
  end

  private
  def shift_params
    params.require(:shift).
      permit(*policy(@shift || Shift).permitted_attributes)
  end

  def date_and_time(date, time)
    DateTime.new(date.year, date.month, date.day, time.hour, time.min, time.sec, time.zone)
  end

  def load_and_authorize_involvement
    params[:involvement_id].presence.try do |iid|
      @involvement = Involvement.find iid
      authorize @involvement, :schedule?
    end
  end
end
