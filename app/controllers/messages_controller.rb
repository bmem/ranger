class MessagesController < ApplicationController
  before_filter :load_subject_record_by_id, except: [:index, :new, :create]
  after_filter :verify_authorized, except: :index
  after_filter :verify_policy_scoped, only: :index

  # GET /messages
  # GET /messages.json
  def index
    @messages = policy_scope(Message)
    @messages = order_by_params(@messages)
    @messages = @messages.page(params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @messages }
    end
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    authorize @message
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/1/changes
  # GET /messages/1/changes.json
  def changes
    authorize @message
    @audits = order_by_params @message.audits, default_sort_column: 'version', default_sort_column_direction: 'desc'
    respond_to do |format|
      format.html # changes.html.haml
      format.json { render json: @audits }
    end
  end

  # GET /messages/new
  # GET /messages/new.json
  def new
    @message = Message.new
    @message.sender = current_user
    authorize @message
    @teams = policy_scope(Team)
    @selected_teams = @teams & Team.find(selected_array_param(params[:team_ids]))
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/1/edit
  def edit
    authorize @message
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new message_params
    @message.sender = current_user
    authorize @message
    ids = selected_array_param(params[:person_ids])
    selected_array_param(params[:team_ids]).each do |tid|
      ids += Team.find(tid).member_ids
    end
    @message.recipient_ids = ids.uniq
    respond_to do |format|
      if @message.recipient_ids.none?
        flash[:notice] = 'No recipients specified'
        format.html { render action: 'new', notice: 'No recipients' }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      else
        if @message.save
          format.html { redirect_to @message, notice: 'Message was successfully created.' }
          format.js # create.js.erb
          format.json { render json: @message, status: :created, location: @message }
        else
          format.html { render action: "new" }
          format.js { render text: @message.errors.full_messages.to_sentence, status: :unprocessable_entity}
          format.json { render json: @message.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PUT /messages/1
  # PUT /messages/1.json
  def update
    authorize @message
    respond_to do |format|
      if @message.update_attributes(message_params)
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /messages/1/deliver?person_id=2
  # POST /messages/1/deliver.json?person_id=2
  def deliver
    person_id = params[:person_id].to_i
    @receipt = @message.receipts.where(recipient_id: person_id).first_or_initialize
    if @receipt.new_record?
      authorize @receipt, :create?
    else
      authorize @receipt, :deliver?
    end
    if params[:undeliver].present?
      @receipt.delivered = false
      status = 'undelivered'
    else
      @receipt.delivered = true
      status = 'delivered'
    end
    if params[:delete].present?
      @receipt.deleted = true
      status = 'deleted'
    end
    respond_to do |format|
      if @receipt.save
        format.html { redirect_to :back, notice: "Message marked #{status}." }
        format.json { head :no_content }
        format.js { head :no_content }
      else
        message = "Could not mark delivered: #{@receipt.errors.full_messages.to_sentence}"
        format.html { redirect_to :back, notice: message }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
        format.js { render 'error_message', locals: {message: message}, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    authorize @message
    @message.destroy

    respond_to do |format|
      format.html { redirect_to messages_url }
      format.json { head :no_content }
    end
  end

  def subject_record
    @message
  end

  protected
  def load_subject_record_by_id
    @message = Message.find(params[:id])
  end

  private
  def message_params
    params.require(:message).
      permit(*policy(@message || Message.new).permitted_attributes)
  end
end
