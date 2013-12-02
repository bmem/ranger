class EventBasedController < ApplicationController
  load_and_authorize_resource
  load_and_authorize_resource :event
  before_filter :ensure_event

  layout 'event_based'

  private
  def ensure_event
    @event ||= subject_record.event if subject_record.respond_to? :event
    @event ||= Event.find(default_event_id) if default_event_id.present?
  end
end
