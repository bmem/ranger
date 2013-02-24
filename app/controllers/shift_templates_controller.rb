class ShiftTemplatesController < ApplicationController
  load_and_authorize_resource

  # GET /shift_templates
  # GET /shift_templates.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @shift_templates }
    end
  end

  # GET /shift_templates/1
  # GET /shift_templates/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @shift_template }
    end
  end

  # GET /shift_templates/new
  # GET /shift_templates/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @shift_template }
    end
  end

  # GET /shift_templates/1/edit
  def edit
  end

  # POST /shift_templates
  # POST /shift_templates.json
  def create
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
    respond_to do |format|
      if @shift_template.update_attributes(params[:shift_template])
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
    @shift_template.destroy

    respond_to do |format|
      format.html { redirect_to shift_templates_url }
      format.json { head :no_content }
    end
  end

  def subject_record
    @shift_template
  end
end
