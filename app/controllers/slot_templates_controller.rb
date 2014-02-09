class SlotTemplatesController < ApplicationController
  before_filter :load_shift_template
  before_filter :load_subject_record_by_id, except: [:index, :new, :create]
  after_filter :verify_authorized, except: :index
  after_filter :verify_policy_scoped, only: :index

  # GET /slot_templates
  # GET /slot_templates.json
  def index
    @slot_templates = policy_scope(
      @shift_template ? @shift_template.slot_templates : ShiftTemplate)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @slot_templates }
    end
  end

  # GET /slot_templates/1
  # GET /slot_templates/1.json
  def show
    authorize @slot_template
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @slot_template }
    end
  end

  # GET /slot_templates/1
  # GET /slot_templates/1.json
  def changes
    authorize @slot_template
    respond_to do |format|
      format.html # changes.html.erb
      format.json { render :json => @slot_template.audits }
    end
  end

  # GET /slot_templates/new
  # GET /slot_templates/new.json
  def new
    @slot_template = @shift_template ? @shift_template.slot_templates.build : SlotTemplate.new
    authorize @slot_template
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @slot_template }
    end
  end

  # GET /slot_templates/1/edit
  def edit
    authorize @slot_template
  end

  # POST /slot_templates
  # POST /slot_templates.json
  def create
    @slot_template = @shift_template ?
      @shift_template.slot_templates.build(slot_template_params) :
      SlotTemplate.new(slot_template_params)
    authorize @slot_template

    respond_to do |format|
      if @slot_template.save
        format.html { redirect_to @shift_template, notice: 'Slot template was successfully created.' }
        format.json { render json: @slot_template, status: :created, location: @slot_template }
      else
        format.html { render action: "new" }
        format.json { render json: @slot_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /slot_templates/1
  # PUT /slot_templates/1.json
  def update
    authorize @slot_template
    respond_to do |format|
      if @slot_template.update_attributes(slot_template_params)
        format.html { redirect_to @slot_template, notice: 'Slot template was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @slot_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /slot_templates/1
  # DELETE /slot_templates/1.json
  def destroy
    authorize @slot_template
    @slot_template.destroy

    respond_to do |format|
      format.html { redirect_to shift_template_slot_templates_url(@shift_template) }
      format.json { head :no_content }
    end
  end

  def subject_record
    @slot_template
  end

  protected
  def load_subject_record_by_id
    @slot_template = SlotTemplate.find(params[:id])
  end

  private
  def slot_template_params
    params.require(:slot_template).
      permit(*policy(@slot_template || SlotTemplate.new).permitted_attributes)
  end

  def load_shift_template
    params[:shift_template_id].presence.try do |stid|
      @shift_template = ShiftTemplate.find(stid)
      authorize @shift_template, :show?
    end
  end
end
