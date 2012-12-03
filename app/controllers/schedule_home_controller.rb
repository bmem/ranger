class ScheduleHomeController < ApplicationController
  skip_load_and_authorize_resource

  def index
    @page_title = "Home"
    events = Event.accessible_by(current_ability)
    upcoming, completed = events.partition {|e| e.upcoming? || e.current?}
    current, upcoming = upcoming.partition {|e| e.current?}
    @current_events = current.sort_by &:end_date
    @upcoming_events = upcoming.sort_by &:start_date
    @completed_events = completed.sort_by(&:end_date).reverse!
  end
end
