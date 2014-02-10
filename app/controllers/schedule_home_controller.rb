class ScheduleHomeController < ApplicationController
  before_filter :authenticate_user!

  def index
    @page_title = "Schedule"
    unless @person = current_user.person
      redirect_to '/', notice: 'No person associated with this user'
      return
    end
    @involvements = @person.involvements
    @involvements_by_event = @involvements.index_by &:event_id
    @upcoming_events = Event.upcoming.signup_open
    @current_events = Event.current.signup_open
    @completed_events = Event.completed.where(:id => @involvements_by_event.keys)
  end
end
