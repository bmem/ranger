class CreditDeltasController < EventBasedController
  before_filter :load_credit_scheme

  # GET /credit_deltas
  # GET /credit_deltas.json
  def index
    @credit_deltas = policy_scope(
      @credit_scheme ? @credit_scheme.credit_deltas : CreditDelta)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @credit_deltas }
    end
  end

  # GET /credit_deltas/1
  # GET /credit_deltas/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @credit_delta }
    end
  end

  # GET /credit_deltas/1/changes
  # GET /credit_deltas/1/changes.json
  def changes
    @audits = order_by_params @credit_delta.audits, default_sort_column: 'version', default_sort_column_direction: 'desc'
    respond_to do |format|
      format.html # changes.html.haml
      format.json { render json: @audits }
    end
  end

  # GET /credit_deltas/new
  # GET /credit_deltas/new.json
  def new
    @credit_delta = @credit_scheme ? @credit_scheme.credit_deltas.build : CreditDelta.new
    @credit_delta.attributes = credit_delta_params if params[:credit_delta].present?
    authorize @credit_delta
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @credit_delta }
    end
  end

  # GET /credit_deltas/1/edit
  def edit
  end

  # POST /credit_deltas
  # POST /credit_deltas.json
  def create
    @credit_delta = if @credit_scheme
                      @credit_scheme.credit_deltas.build(credit_delta_params)
                    else
                      CreditDelta.new(credit_delta_params)
                    end
    authorize @credit_delta
    respond_to do |format|
      if @credit_delta.save
        format.html { redirect_to @credit_delta, :notice => 'Credit delta was successfully created.' }
        format.json { render :json => @credit_delta, :status => :created, :location => @credit_delta }
      else
        format.html { render :action => "new" }
        format.json { render :json => @credit_delta.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /credit_deltas/1
  # PUT /credit_deltas/1.json
  def update
    respond_to do |format|
      if @credit_delta.update_attributes(credit_delta_params)
        format.html { redirect_to @credit_delta, :notice => 'Credit delta was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @credit_delta.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /credit_deltas/1
  # DELETE /credit_deltas/1.json
  def destroy
    @credit_delta.destroy

    respond_to do |format|
      format.html { redirect_to event_credit_scheme_credit_deltas_url(@event, @credit_scheme) }
      format.json { head :no_content }
    end
  end

  def subject_record
    @credit_delta
  end

  def load_subject_record_by_id
    @credit_delta = CreditDelta.find params[:id]
  end

  private
  def credit_delta_params
    params.require(:credit_delta).
      permit(*policy(@credit_delta || CreditDelta.new).permitted_attributes)
  end

  def load_credit_scheme
    @credit_scheme = @credit_delta ? @credit_delta.credit_scheme :
      params[:credit_scheme_id].presence.try {|csid| CreditScheme.find csid}
  end
end
