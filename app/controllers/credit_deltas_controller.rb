class CreditDeltasController < EventBasedController
  load_and_authorize_resource :credit_scheme

  # GET /credit_deltas
  # GET /credit_deltas.json
  def index
    @credit_deltas = @credit_deltas.where(:credit_scheme_id => @credit_scheme.id) if @credit_scheme
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @credit_deltas }
    end
  end

  # GET /credit_deltas/1
  # GET /credit_deltas/1.json
  def show
    @credit_scheme = @credit_delta.credit_scheme
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @credit_delta }
    end
  end

  # GET /credit_deltas/new
  # GET /credit_deltas/new.json
  def new
    @credit_delta.credit_scheme = @credit_scheme
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
    @credit_delta.credit_scheme = @credit_scheme if @credit_scheme
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
      if @credit_delta.update_attributes(params[:credit_delta])
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
      format.html { redirect_to credit_deltas_url }
      format.json { head :no_content }
    end
  end

  def subject_record
    @credit_delta
  end
end
