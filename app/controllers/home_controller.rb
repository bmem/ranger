class HomeController < ApplicationController
  def index
    if current_user
      @person = current_user.person
      select_interesting_events
      respond_to do |format|
        format.html { render action: :loggedin}
      end
    else
      respond_to do |format|
        format.html { render action: :loggedout}
      end
    end
  end

  private
  def select_interesting_events
    @interesting_events = []
    @interesting_events += Event.current
    @interesting_events += Event.upcoming
    @interesting_events += Event.completed.limit(2)
    default_event_id.try {|id| @interesting_events << Event.find(id)}
    @interesting_events.uniq!
  end
end
