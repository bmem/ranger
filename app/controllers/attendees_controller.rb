class AttendeesController < EventBasedController
  before_filter :load_and_authorize_slot
  before_filter :load_and_authorize_involvement

  # GET /events/1/attendees
  # GET /events/1/attendees.json
  # GET /events/1/slots/2/attendees
  # GET /events/1/slots/2/attendees.json
  # GET /events/1/involvements/3/attendees
  # GET /events/1/involvements/3/attendees.json
  def index
    @attendees = if @slot
                   @slot.attendees
                 elsif @involvement
                   @involvement.attendees
                 else
                   @event.attendees
                 end
    @attendees = @attendees.includes(:slot)
    @attendees = @attendees.includes(:involvement)
    @attendees = policy_scope(@attendees)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @attendees }
    end
  end

  # GET /attendees/1
  # GET /attendees/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @attendee }
    end
  end

  # GET /attendees/1/audits
  # GET /attendees/1/audits.json
  def changes
    respond_to do |format|
      format.html # changes.html.haml
      format.json { render json: @attendee.audits }
    end
  end


  # GET /attendees/new?slot_id=1&involvement_id=2
  # GET /attendees/new.json?slot_id=1&involvement_id=2
  def new
    @attendee = Attendee.new status: Attendee::STATUSES.first
    @attendee.slot = @slot
    @attendee.involvement = @involvement
    authorize @attendee
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @attendee }
    end
  end

  # GET /attendees/1/edit
  def edit
  end

  # POST /attendees
  # POST /attendees.json
  def create
    @attendee = Attendee.new attendee_params
    @attendee.slot = @slot
    if @involvement
      @attendee.involvement = @involvement
    else
      @attendee.involvement_id = params[:attendee][:involvement_id]
    end
    authorize @attendee
    respond_to do |format|
      if @attendee.save
        format.html { redirect_to request.env['HTTP_REFERER'].presence || @attendee, notice: "#{@attendee} created" }
        format.json { render json: @attendee, status: :created, location: @attendee }
      else
        format.html { render action: "new" }
        format.json { render json: @attendee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /attendees/1
  # PUT /attendees/1.json
  def update
    respond_to do |format|
      if @attendee.update_attributes(attendee_params)
        format.html { redirect_to @attendee, notice: "#{@attendee} updated"}
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @attendee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attendees/1
  # DELETE /attendees/1.json
  def destroy
    @attendee.destroy
    respond_to do |format|
      format.html { redirect_to request.env['HTTP_REFERER'].presence || event_slot_attendees_path(@event, @attendee.slot), notice: "#{@attendee} removed" }
      format.json { head :no_content }
    end
  end

  def subject_record
    @attendee
  end

  def load_subject_record_by_id
    @attendee = Attendee.find(params[:id])
  end

  private
  def attendee_params
    params.permit(:attendee).
      permit(*policy(@attendee || Attendee.new).permitted_attributes)
  end

  def load_and_authorize_slot
    params[:slot_id].presence.try do |slot_id|
      @slot = Slot.find slot_id
      authorize @slot, :show?
    end
  end

  def load_and_authorize_involvement
    params[:involvement_id].presence.try do |iid|
      @involvement = Involvement.find iid
      authorize @involvement, :show?
    end
  end
end
