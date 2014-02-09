class ShiftTemplatesController < ApplicationController
  before_filter :load_subject_record_by_id, except: [:index, :new, :create]
  after_filter :verify_authorized, except: :index
  after_filter :verify_policy_scoped, only: :index

  # GET /shift_templates
  # GET /shift_templates.json
  def index
    @shift_templates = policy_scope(ShiftTemplate)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @shift_templates }
    end
  end

  # GET /shift_templates/1
  # GET /shift_templates/1.json
  def show
    authorize @shift_template
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @shift_template }
    end
  end

  # GET /shift_templates/1
  # GET /shift_templates/1.json
  def changes
    authorize @shift_template
    respond_to do |format|
      format.html # changes.html.erb
      format.json { render :json => @shift_template.audits }
    end
  end

  # GET /shift_templates/new
  # GET /shift_templates/new.json
  def new
    @shift_template = ShiftTemplate.new
    authorize @shift_template
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @shift_template }
    end
  end

  # GET /shift_templates/1/edit
  def edit
    authorize @shift_template
  end

  # POST /shift_templates
  # POST /shift_templates.json
  def create
    @shift_template = ShiftTemplate.new shift_template_params
    authorize @shift_template
    respond_to do |format|
      if @shift_template.save
        format.html { redirect_to @shift_template, notice: 'Shift template was successfully created.' }
        format.json { render json: @shift_template, status: :created, location: @shift_template }
      else
        format.html { render action: "new" }
        format.json { render json: @shift_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /shift_templates/1
  # PUT /shift_templates/1.json
  def update
    authorize @shift_template
    respond_to do |format|
      if @shift_template.update_attributes(shift_template_params)
        format.html { redirect_to @shift_template, notice: 'Shift template was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @shift_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shift_templates/1
  # DELETE /shift_templates/1.json
  def destroy
    authorize @shift_template
    @shift_template.destroy

    respond_to do |format|
      format.html { redirect_to shift_templates_url }
      format.json { head :no_content }
    end
  end

  def subject_record
    @shift_template
  end

  protected
  def load_subject_record_by_id
    @shift_template = ShiftTemplate.find(params[:id])
  end

  private
  def shift_template_params
    params.require(:shift_template).
      permit(*policy(@shift_template || ShiftTemplate.new).permitted_attributes)
  end
end
