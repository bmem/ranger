class EventBasedController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_event_by_id
  before_filter :load_and_authorize_by_id, if: :should_load_and_authorize
  before_filter :ensure_event
  after_filter :verify_authorized, unless: :should_skip_verify_authorized
  after_filter :verify_policy_scoped, if: :should_verify_policy_scoped

  layout 'event_based'

  protected
  def load_and_authorize_by_id
    load_subject_record_by_id
    authorize subject_record
  end

  def should_load_and_authorize
    respond_to? :load_subject_record_by_id and params[:id].present?
  end

  def should_skip_verify_authorized
    skip_verify_authorized_actions.include? action_name.to_sym
  end

  def should_verify_policy_scoped
    verify_policy_scoped_actions.include? action_name.to_sym
  end

  def skip_verify_authorized_actions
    [:index, :search, :typeahead]
  end

  def verify_policy_scoped_actions
    [:index, :search, :typeahead]
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
