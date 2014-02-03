class EventBasedController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :load_event_by_id
  before_filter :load_and_authorize_by_id, if: :should_load_and_authorize
  before_filter :ensure_event

  layout 'event_based'

  protected
  def load_and_authorize_by_id
    load_subject_record_by_id
    authorize subject_record
  end

  def should_load_and_authorize
    respond_to? :load_subject_record_by_id and params[:id].present?
  end

  def load_event_by_id
    if params[:event_id].present?
      @event = Event.find(params[:event_id])
    end
  end

  def ensure_event
    @event ||= subject_record.event if subject_record.respond_to? :event
    @event ||= Event.find(default_event_id) if default_event_id.present?
  end
end
