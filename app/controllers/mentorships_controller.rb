class MentorshipsController < EventBasedController
  # GET /mentorships
  # GET /mentorships.json
  def index
    @mentorships = policy_scope(@event.mentorships)
    @mentorships = @mentorships.includes(:shift).includes(:mentee)
    @mentorships = order_by_params @mentorships

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mentorships }
    end
  end

  # GET /mentorships/1
  # GET /mentorships/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @mentorship }
    end
  end

  # GET /mentorships/1/changes
  # GET /mentorships/1/changes.json
  def changes
    @audits = order_by_params @mentorship.audits, default_sort_column: 'version', default_sort_column_direction: 'desc'
    respond_to do |format|
      format.html # changes.html.haml
      format.json { render json: @audits }
    end
  end

  # GET /mentorships/new
  # GET /mentorships/new.json
  def new
    @mentorship = @event.mentorships.build
    @mentorship.outcome = Mentorship::OUTCOMES.first
    params['mentee_id'].try do |mid|
      @mentorship.mentee = Involvement.find mid
    end
    params['shift_id'].try do |sid|
      @mentorship.shift = Shift.find sid
    end
    authorize @mentorship
    respond_to do |format|
      if @mentorship.valid?
        format.html
        format.json { render json: @mentorship }
      else
        format.html { render action: 'new', notice: "Must specify mentee and shift parameters" }
        format.json { render json: @mentorship.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /mentorships/1/edit
  def edit
  end

  # POST /mentorships
  # POST /mentorships.json
  def create
    @mentorship = @event.mentorships.build mentorship_params
    params['mentee_id'].presence.try {|mid| @mentorship.mentee = Involvement.find mid }
    params['shift_id'].presence.try {|sid| @mentorship.shift = Shift.find sid}
    authorize @mentorship
    respond_to do |format|
      if @mentorship.save
        format.html { redirect_to [@mentorship.event, @mentorship], notice: 'Mentorship was successfully created.' }
        format.json { render json: @mentorship, status: :created, location: @mentorship }
      else
        format.html { render action: "new" }
        format.json { render json: @mentorship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /mentorships/1
  # PUT /mentorships/1.json
  def update
    respond_to do |format|
      if @mentorship.update_attributes(mentorship_params)
        format.html { redirect_to [@mentorship.event, @mentorship], notice: 'Mentorship was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @mentorship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mentorships/1
  # DELETE /mentorships/1.json
  def destroy
    @mentorship.destroy

    respond_to do |format|
      format.html { redirect_to event_mentorships_url(@mentorship.event_id) }
      format.json { head :no_content }
    end
  end

  def subject_record
    @mentorship
  end

  def load_subject_record_by_id
    @mentorship = @event.mentorships.find(params[:id])
  end

  def default_sort_column
    'shifts.start_time'
  end

  private
  def mentorship_params
    params.require(:mentorship).
      permit(*policy(@mentorship || Mentorship.new).permitted_attributes)
  end
end
