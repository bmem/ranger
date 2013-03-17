class SlotsController < EventBasedController
  load_and_authorize_resource :shift, :class => Shift
  skip_authorize_resource :only => [:join, :leave]

  # GET /slots
  # GET /slots.json
  def index
    @slots = @slots.joins(:shift).where('shifts.event_id' => @event.id) if @event
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

  # GET /slots/new
  # GET /slots/new.json
  def new
    @slot.shift = @shift if @shift
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
      if @slot.update_attributes(params[:slot])
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
    if params[:involvement_id].present?
      @involvement = Involvement.find(params[:involvement_id])
    elsif params[:person_id].present?
      person = Person.find(params[:person_id])
      @involvement = person.involvements.find_by_event_id @shift.event_id
    end
    authorize! :edit, @involvement
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
          format.html { redirect_to :back, :notice => "#{@involvement} was added to slot."}
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
    if params[:involvement_id].present?
      @involvement = Involvement.find(params[:involvement_id])
    elsif params[:person_id].present?
      person = Person.find(params[:person_id])
      @involvement = person.involvements.find_by_event_id @shift.event_id
    end
    authorize! :edit, @involvement
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
end
