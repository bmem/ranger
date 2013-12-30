class ReportsController < EventBasedController
  load_and_authorize_resource

  # GET /reports
  # GET /reports.json
  def index
    @reports = @reports.where event_id: @event.id if @event
    @reports = order_by_params @reports
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reports }
    end
  end

  # GET /reports/1
  # GET /reports/1.json
  # GET /reports/1.csv
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @report }
      format.csv {render csv: @report.report_object, filename: @report.name}
    end
  end

  # GET /reports/1/changes
  # GET /reports/1/changes.json
  def changes
    @report = Report.find(params[:id])
    authorize! :audit, @report
    @audits = order_by_params @report.audits, default_sort_column: 'version', default_sort_column_direction: 'desc'
    respond_to do |format|
      format.html # changes.html.haml
      format.json { render json: @audits }
    end
  end

  # GET /reports/1/edit
  def edit
  end

  # PUT /reports/1
  # PUT /reports/1.json
  def update
    respond_to do |format|
      if @report.update_attributes(params[:report])
        format.html do
          target = @event ? [@event, @report] : @report
          redirect_to target, notice: 'Report was successfully updated.'
        end
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    @report.destroy

    respond_to do |format|
      format.html { redirect_to @event ? event_reports_url(@event) : reports_url }
      format.json { head :no_content }
    end
  end

  # POST /reports/generate/Birthday
  def generate
    raise 'Missing report name' unless params[:report_name].present?
    klass = (params[:report_name] + 'Report').constantize
    parameters = params[:parameters] || {}
    if @event
      parameters[:event_id] = @event.id
    elsif parameters[:event_id].present?
      @event = Event.find(parameters[:event_id])
    end
    report = klass.new parameters
    result = report.generate
    @report = Report.new name: result.report.title
    @report.user = current_user
    @report.event = @event
    @report.report_object = result.report
    @report.num_results = result.num_results
    result.readable_parameters.try {|rp| @report.readable_parameters = rp}

    respond_to do |format|
      if @report.save
        format.html do
          target = @event ? [@event, @report] : @report
          redirect_to target, notice: "#{@report.name} report generated."
        end
        format.any(:csv, :json) {redirect_to @report, format: request.format}
      else
        format.html {redirect_to :back, notice: "Report errors: #{@report.errors.full_messages.join('. ')}"}
        format.csv {render :status => :unprocessable_entity}
        format.json {render :json => @report.errors, :status => :unprocessable_entity}
      end
    end
  end

  def subject_record
    @report
  end

  def default_sort_column
    'created_at'
  end

  def default_sort_column_direction
    'desc'
  end
end
