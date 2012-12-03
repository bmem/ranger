class SlotsController < EventBasedController
  load_and_authorize_resource :shift, :class => Shift

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
