class TrainingsController < EventBasedController
  # GET /trainings
  # GET /trainings.json
  def index
    @trainings = @trainings.includes(:shift).where('shifts.event_id = ?', @event.id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @trainings }
    end
  end

  # GET /trainings/1
  # GET /trainings/1.json
  def show
    @training = Training.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @training }
    end
  end

  # GET /trainings/new
  # GET /trainings/new.json
  def new
    @training.build_shift(:event => @event)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @training }
    end
  end

  # GET /trainings/1/edit
  def edit
    @training = Training.find(params[:id])
  end

  # POST /trainings
  # POST /trainings.json
  def create
    @training.build_shift(:event => @event) unless @training.shift
    @training.shift.event ||= @event
    @training.shift.training = @training

    respond_to do |format|
      if @training.save
        format.html { redirect_to [@event, @training], :notice => 'Training was successfully created.' }
        format.json { render :json => @training, :status => :created, :location => @training }
      else
        format.html { render :action => "new" }
        format.json { render :json => @training.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /trainings/1
  # PUT /trainings/1.json
  def update
    respond_to do |format|
      if @training.update_attributes(params[:training])
        format.html { redirect_to [@event, @training], :notice => 'Training was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @training.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /trainings/1
  # DELETE /trainings/1.json
  def destroy
    @training.destroy

    respond_to do |format|
      format.html { redirect_to event_trainings_url(@event) }
      format.json { head :no_content }
    end
  end

  def subject_record
    @training
  end
end
