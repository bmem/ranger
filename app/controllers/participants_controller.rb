class ParticipantsController < EventBasedController
  # GET /participants
  # GET /participants.json
  def index
    @participants = @participants.where(:event_id => @event.id) if @event
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @participants }
    end
  end

  # GET /participants/1
  # GET /participants/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @participant }
    end
  end

  # GET /participants/new
  # GET /participants/new.json
  def new
    @participant.event ||= @event
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @participant }
    end
  end

  # GET /participants/1/edit
  def edit
  end

  # POST /participants
  # POST /participants.json
  def create
    respond_to do |format|
      if @participant.save
        format.html { redirect_to @participant, :notice => 'Participant was successfully created.' }
        format.json { render :json => @participant, :status => :created, :location => @participant }
      else
        format.html { render :action => "new" }
        format.json { render :json => @participant.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /participants/1
  # PUT /participants/1.json
  def update
    respond_to do |format|
      if @participant.update_attributes(params[:participant])
        format.html { redirect_to @participant, :notice => 'Participant was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @participant.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /participants/1
  # DELETE /participants/1.json
  def destroy
    @participant.destroy

    respond_to do |format|
      format.html { redirect_to participants_url }
      format.json { head :no_content }
    end
  end

  def subject_record
    @participant
  end
end
