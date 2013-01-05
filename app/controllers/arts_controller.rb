class ArtsController < ApplicationController
  load_and_authorize_resource

  # GET /arts
  # GET /arts.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @arts }
    end
  end

  # GET /arts/1
  # GET /arts/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @art }
    end
  end

  # GET /arts/new
  # GET /arts/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @art }
    end
  end

  # GET /arts/1/edit
  def edit
  end

  # POST /arts
  # POST /arts.json
  def create
    respond_to do |format|
      if @art.save
        format.html { redirect_to @art, notice: 'Art was successfully created.' }
        format.json { render json: @art, status: :created, location: @art }
      else
        format.html { render action: "new" }
        format.json { render json: @art.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /arts/1
  # PUT /arts/1.json
  def update
    respond_to do |format|
      if @art.update_attributes(params[:art])
        format.html { redirect_to @art, notice: 'Art was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @art.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /arts/1
  # DELETE /arts/1.json
  def destroy
    @art.destroy

    respond_to do |format|
      format.html { redirect_to arts_url }
      format.json { head :no_content }
    end
  end

  def subject_record
    @art
  end
end
