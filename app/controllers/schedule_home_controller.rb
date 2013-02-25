class ScheduleHomeController < ApplicationController
  skip_load_and_authorize_resource

  def index
    @page_title = "Schedule"
    unless current_user and @person = current_user.person
      raise CanCan::AccessDenied.new('Not logged in')
    end
    @involvements = @person.involvements
    @involvements_by_event = @involvements.index_by &:event_id
    @upcoming_events = Event.upcoming.signup_open
    @current_events = Event.current.signup_open
    @completed_events = Event.completed.where(:id => @involvements_by_event.keys)
  end
end
