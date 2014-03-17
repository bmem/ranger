class SlotsController < EventBasedController
  before_filter :load_shift
  before_filter :load_and_authorize_involvement

  # GET /slots
  # GET /slots.json
  def index
    if @shift
      @slots = policy_scope(@shift.slots)
    else
      @slots = policy_scope(Slot).with_shift
      @slots = @slots.where('shifts.event_id' => @event.id) if @event
    end
    @slots = @slots.includes(:position)
    selected_array_param(params[:position_id]).presence.try do |position_ids|
      @slots = @slots.where(position_id: position_ids)
    end
    @possible_positions = policy_scope(Position)
    @query_position_ids = selected_array_param(params[:position_id]).map(&:to_i)
    if @query_position_ids.any?
      @query_position_ids &= @possible_positions.map(&:id)
      @slots = @slots.where(position_id: @query_position_ids)
    else
      @query_position_ids = @possible_positions.map(&:id)
    end
    @slots = order_by_params @slots
    @slots = @slots.page(params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @slots }
    end
  end

  # GET /slots/1
  # GET /slots/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @slot }
    end
  end

  # GET /slots/1/changes
  # GET /slots/1/changes.json
  def changes
    @audits = order_by_params @slot.audits, default_sort_column: 'version', default_sort_column_direction: 'desc'
    respond_to do |format|
      format.html # changes.html.haml
      format.json { render json: @audits }
    end
  end

  # GET /slots/new
  # GET /slots/new.json
  def new
    @slot = @shift ? @shift.slots.build : Slot.new
    authorize @slot
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @slot }
    end
  end

  # GET /slots/1/edit
  def edit
  end

  # POST /slots
  # POST /slots.json
  def create
    @slot = @shift ? @shift.slots.build(slot_params) : Slot.new(slot_params)
    authorize @slot
    respond_to do |format|
      if @slot.save
        format.html { redirect_to @slot, :notice => 'Slot was successfully created.' }
        format.json { render :json => @slot, :status => :created, :location => @slot }
      else
        format.html { render :action => "new" }
        format.json { render :json => @slot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /slots/1
  # PUT /slots/1.json
  def update
    respond_to do |format|
      if @slot.update_attributes(slot_params)
        format.html { redirect_to @slot, :notice => 'Slot was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @slot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # POST /slots/1/join
  # POST /sots/1/join.json
  def join
    @slot = Slot.find(params[:id])
    authorize @slot, :show? # TODO authorize a join model
    if params[:involvement_id].present?
      @involvement = Involvement.find(params[:involvement_id])
    elsif params[:person_id].present?
      person = Person.find(params[:person_id])
      @involvement = person.involvements.find_by_event_id @shift.event_id
    end
    authorize @involvement, :schedule?
    respond_to do |format|
      if not @event.signup_open?
        error = "#{@event} is not open for signups."
        format.html { redirect_to :back, :alert => error }
        format.json { render :json => error, :status => :unprocessable_entity }
      elsif not @slot.position_id.in? @involvement.position_ids
        format.html { redirect_to :back, :alert => "#{@involvement} does not have position #{@slot.position}. Cannot add to slot." }
        format.json { render :json => @slot.errors, :status => :unprocessable_entity }
      elsif @slot.shift_id.in? @involvement.slots.map(&:shift_id)
        error = "#{@involvement} is already signed up for #{@slot.shift}. Cannot add to slot."
        format.html { redirect_to :back, :alert => error}
        format.json { render :json => error, :status => :unprocessable_entity }
      else
        @involvement.slots << @slot
        if @involvement.save
          format.html { redirect_to :back, :notice => "#{@involvement} was added to #{@slot}."}
          format.json { head :no_content }
        else
          format.html { redirect_to :back, :alert => "Could not add #{@involvement} to slot" }
          format.json { render :json => @involvement.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # POST /slots/1/leave
  # POST /sots/1/leave.json
  def leave
    @slot = Slot.find(params[:id])
    authorize @slot, :show? # TODO authorize a join model
    if params[:involvement_id].present?
      @involvement = Involvement.find(params[:involvement_id])
    elsif params[:person_id].present?
      person = Person.find(params[:person_id])
      @involvement = person.involvements.find_by_event_id @shift.event_id
    end
    authorize @involvement, :schedule?
    respond_to do |format|
      unless @slot.id.in? @involvement.slot_ids
        format.html { redirect_to :back, :alert => "#{@involvement} is not signed up for #{@slot}." }
        format.json { render :json => @slot.errors, :status => :unprocessable_entity }
      else
        @involvement.slots.delete @slot
        if @involvement.save
          format.html { redirect_to :back, :notice => "#{@involvement} was removed from slot."}
          format.json { head :no_content }
        else
          format.html { redirect_to :back, :alert => "Could not remove #{@involvement} from slot." }
          format.json { render :json => @involvement.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /slots/1
  # DELETE /slots/1.json
  def destroy
    @slot.destroy

    respond_to do |format|
      format.html { redirect_to slots_url }
      format.json { head :no_content }
    end
  end

  def subject_record
    @slot
  end

  def load_subject_record_by_id
    @slot = Slot.find(params[:id])
  end

  def default_sort_column
    'shifts.start_time'
  end

  protected
  def should_load_and_authorize
    super and not [:join, :leave].include? params[:action].to_sym
  end

  private
  def slot_params
    params.require(:slot).
      permit(*policy(@slot || Slot).permitted_attributes)
  end

  def load_shift
    @shift = if @slot
               @slot.shift
             elsif params[:shift_id].present?
               Shift.find(params[:shift_id])
             end
  end

  def load_and_authorize_involvement
    params[:involvement_id].presence.try do |iid|
      @involvement = Involvement.find iid
      authorize @involvement, :schedule?
    end
  end
end
