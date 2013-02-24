class SlotTemplatesController < ApplicationController
  load_and_authorize_resource :shift_template
  load_and_authorize_resource

  # GET /slot_templates
  # GET /slot_templates.json
  def index
    @slot_templates = @shift_template.slot_templates if @shift_template
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @slot_templates }
    end
  end

  # GET /slot_templates/1
  # GET /slot_templates/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @slot_template }
    end
  end

  # GET /slot_templates/new
  # GET /slot_templates/new.json
  def new
    @slot_template.shift_template = @shift_template
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @slot_template }
    end
  end

  # GET /slot_templates/1/edit
  def edit
  end

  # POST /slot_templates
  # POST /slot_templates.json
  def create
    respond_to do |format|
      if @slot_template.save
        format.html { redirect_to [shift_slot], notice: 'Slot template was successfully created.' }
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
    respond_to do |format|
      if @slot_template.update_attributes(params[:slot_template])
        format.html { redirect_to [shift_slot], notice: 'Slot template was successfully updated.' }
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
    @slot_template.destroy

    respond_to do |format|
      format.html { redirect_to shift_template_slot_templates_url(@shift_template) }
      format.json { head :no_content }
    end
  end

  def subject_record
    @slot_template
  end

  private
  def shift_slot
    [@shift_template, @slot_template]
  end
end
