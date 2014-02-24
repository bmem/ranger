class InvolvementsController < EventBasedController
  # GET /involvements
  # GET /involvements.json
  def index
    set_statuses_from_params
    @involvements = policy_scope(Involvement)
    @involvements = @involvements.where(:event_id => @event.id) if @event
    filter_by_status
    @involvements = order_by_params(@involvements)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @involvements }
    end
  end

  # GET /events/:event_id/involvements/search?q=foo
  def search
    @query = params[:q]
    set_statuses_from_params
    @involvements = policy_scope(Involvement)
    if @query.blank? and @personnel_statuses.none? and @involvement_statuses.none?
      @involvements = @involvements.where('1 = 0')
      flash.notice = 'Empty search query'
    else
      @query = @query.to_ascii
      @involvements = @involvements.where(event_id: @event.id) if @event
      filter_by_status
      @involvements = order_by_params(@involvements)
      before_query = @involvements
      @involvements = @involvements.with_query(@query)
      if @involvements.none?
        # try a prefix query
        unless @query.starts_with? '^' or @query =~ /\s/
          @query = '^' + @query
          @involvements = before_query.with_query(@query)
        end
        flash.notice = "No people found in #{@event}" if @involvements.none?
      end
    end
    respond_to do |format|
      format.html # search.html.haml
      format.json { render json: @involvements }
    end
  end

  # GET /events/:event_id/involvements/typehead.json
  def typeahead
    @involvements = policy_scope(Involvement)
    @involvements = @involvements.where(event_id: @event.id)
    @dataset = @involvements.map &:to_typeahead_datum
    respond_to do |format|
      format.json { render :json => @dataset }
    end
  end

  # GET /involvements/1
  # GET /involvements/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json do
        render json: @involvement, include: {
          positions: {only: [:id, :name]},
          slots: {include: {shift: {}, position: {only: [:id, :name]}}}
        }
      end
    end
  end

  # GET /involvements/1/changes
  # GET /involvements/1/changes.json
  def changes
    @audits = order_by_params @involvement.audits, default_sort_column: 'version', default_sort_column_direction: 'desc'
    respond_to do |format|
      format.html # changes.html.haml
      format.json { render json: @audits }
    end
  end

  # GET /involvements/new
  # GET /involvements/new.json
  def new
    @involvement = Involvement.new
    @involvement.event ||= @event
    @involvement.person_id ||= params[:person_id].presence.to_i
    authorize @involvement
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @involvement }
    end
  end

  # GET /involvements/1/edit
  def edit
  end

  # POST /involvements
  # POST /involvements.json
  def create
    @involvement = Involvement.new
    @involvement.event = @event if @event
    person_id = params[:person_id].presence || params[:involvement][:person_id]
    @involvement.person = Person.find person_id
    authorize @involvement
    @involvement.attributes = involvement_params
    respond_to do |format|
      if @involvement.save
        format.html { redirect_to [@involvement.event, @involvement], :notice => 'Involvement was successfully created.' }
        format.json { render :json => @involvement, :status => :created, :location => @involvement }
      else
        format.html { render :action => "new" }
        format.json { render :json => @involvement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /involvements/1
  # PUT /involvements/1.json
  def update
    respond_to do |format|
      if @involvement.update_attributes(involvement_params)
        format.html { redirect_to [@involvement.event, @involvement], :notice => 'Involvement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @involvement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /involvements/1
  # DELETE /involvements/1.json
  def destroy
    @involvement.destroy

    respond_to do |format|
      format.html { redirect_to event_involvements_url(@involvement.event) }
      format.json { head :no_content }
    end
  end

  # GET /involvements/1/schedule
  def schedule
    respond_to do |format|
      format.html # schedule.html.haml
      format.json { render json: @involvement.slots }
    end
  end

  def signup
    if @involvement.positions.empty?
      @slots = []
    else
      @slots = @event.slots.where(:position_id => @involvement.position_ids)
    end
    respond_to do |format|
      format.html { render :action => "signup" }
      format.json { head :no_content }
    end
  end

  def load_subject_record_by_id
    @involvement = Involvement.find(params[:id])
  end

  def subject_record
    @involvement
  end

  def default_sort_column
    'involvements.name'
  end

  private
  def involvement_params
    params.require(:involvement).
      permit(*policy(@involvement || Involvement).permitted_attributes)
  end

  def set_statuses_from_params
    @personnel_statuses = selected_array_param(params[:status])
    @involvement_statuses = selected_array_param(params[:involvement_status])
  end

  def filter_by_status
    @personnel_statuses.try do |ps|
      @involvements = @involvements.where(personnel_status: ps) if ps.any?
    end
    @involvement_statuses.try do |is|
      @involvements = @involvements.where(involvement_status: is) if is.any?
    end
  end
end
