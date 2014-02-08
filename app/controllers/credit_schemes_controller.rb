class CreditSchemesController < EventBasedController
  # GET /credit_schemes
  # GET /credit_schemes.json
  def index
    @credit_schemes = policy_scope(CreditScheme)
    @credit_schemes = @credit_schemes.where(:event_id => @event.id) if @event
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @credit_schemes }
    end
  end

  # GET /credit_schemes/1
  # GET /credit_schemes/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @credit_scheme }
    end
  end

  # GET /credit_schemes/1/changes
  # GET /credit_schemes/1/changes.json
  def changes
    @audits = order_by_params @credit_scheme.audits, default_sort_column: 'version', default_sort_column_direction: 'desc'
    respond_to do |format|
      format.html # changes.html.haml
      format.json { render json: @audits }
    end
  end

  # GET /credit_schemes/new
  # GET /credit_schemes/new.json
  def new
    @credit_scheme = @event ? @event.credit_schemes.build : CreditScheme.new
    authorize @credit_scheme
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @credit_scheme }
    end
  end

  # GET /credit_schemes/1/edit
  def edit
  end

  # POST /credit_schemes
  # POST /credit_schemes.json
  def create
    @credit_scheme = @event ? @event.credit_schemes.build(credit_scheme_params) : CreditScheme.new(credit_scheme_params)
    authorize @credit_scheme
    respond_to do |format|
      if @credit_scheme.save
        format.html { redirect_to @credit_scheme, :notice => 'Credit scheme was successfully created.' }
        format.json { render :json => @credit_scheme, :status => :created, :location => @credit_scheme }
      else
        format.html { render :action => "new" }
        format.json { render :json => @credit_scheme.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /credit_schemes/1
  # PUT /credit_schemes/1.json
  def update
    respond_to do |format|
      if @credit_scheme.update_attributes(credit_scheme_params)
        format.html { redirect_to @credit_scheme, :notice => 'Credit scheme was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @credit_scheme.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /credit_schemes/1
  # DELETE /credit_schemes/1.json
  def destroy
    @credit_scheme.destroy
    respond_to do |format|
      format.html { redirect_to credit_schemes_url }
      format.json { head :no_content }
    end
  end

  def subject_record
    @credit_scheme
  end

  def load_subject_record_by_id
    @credit_scheme = CreditScheme.find(params[:id])
  end

  private
  def credit_scheme_params
    params.require(:credit_scheme).
      permit(*policy(@credit_scheme || CreditScheme.new).permitted_attributes)
  end
end
