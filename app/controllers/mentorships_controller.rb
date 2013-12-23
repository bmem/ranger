class MentorshipsController < EventBasedController
  # GET /mentorships
  # GET /mentorships.json
  def index
    @mentorships = @mentorships.where(event_id: @event.id)
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

  # GET /mentorships/new
  # GET /mentorships/new.json
  def new
    @mentorship.event = @event
    params['mentee_id'].try do |mid|
      @mentorship.mentee = Involvement.find mid
    end
    params['shift_id'].try do |sid|
      @mentorship.shift = Shift.find sid
    end
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
    @mentorship.event = @event
    @mentorship.mentee = Involvement.find params['mentee_id']
    @mentorship.shift = Shift.find params['shift_id'] if params['shift_id'].present?
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
      if @mentorship.update_attributes(params[:mentorship])
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

  def default_sort_column
    'shifts.start_time'
  end
end
