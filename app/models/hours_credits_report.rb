class HoursCreditsReport
  include TimeHelper

  def initialize(parameters)
    @event_id = parameters[:event_id]
    @team_ids = parameters[:team_ids] || []
    @statuses = parameters[:involvement_statuses] || []
    @statuses = %w(confirmed) if @statuses.none?
  end

  def generate
    event = Event.find(@event_id)
    teams = @team_ids.map {|id| Team.find(id)}
    if event.is_a? BurningMan
      year = event.start_date.year
      labor_day = Date.new(year, 9, 6).monday # first Monday of September
      gate_open = labor_day - 8.days # Sunday, 18:00
      event_start = Time.zone.local(year, 8, gate_open.day, 18, 0)
      event_end = Time.zone.local(year, 9, labor_day.day + 1, 0, 0)
    else
      s = event.start_date
      e = event.end_date
      event_start = event.start_date.to_time_in_current_zone
      event_end = event.end_date.to_time_in_current_zone + 1.day
    end
    columns = [:callsign, :status, :total_hours, :total_credits,
      :pre_event_hours, :pre_event_credits, :event_hours, :event_credits,
      :post_event_hours, :post_event_credits, :full_name, :email,
      :mailing_address]
    labels = ['Callsign', 'Status', 'Total Hours', 'Total Credits',
      'Pre-Event Hours', 'Pre-Event Credits', 'Event Hours', 'Event Credits',
      'Post-Event Hours', 'Post-Event Credits', 'Full Name', 'Email',
      'Mailing Address']
    result = Reporting::KeyValueReport.new key_order: columns,
      key_labels: labels, title: "Hours and Credits #{event}"
    involvements = event.involvements.includes(:person).includes(:profile).
      where(involvement_status: @statuses)
    if teams.any?
      involvements = involvements.where(person_id: teams.map(&:person_ids).uniq)
    end
    sum = Hash.new(0)
    involvements.each do |inv|
      result.add_entry callsign: inv.name,
        status: inv.personnel_status,
        total_hours: inv.total_hours_formatted,
        total_credits: inv.total_credits_formatted,
        pre_event_hours: inv.total_hours_formatted(end_time: event_start),
        pre_event_credits: inv.total_credits_formatted(end_time: event_start),
        event_hours: inv.total_hours_formatted(
          start_time: event_start, end_time: event_end),
        event_credits: inv.total_credits_formatted(
          start_time: event_start, end_time: event_end),
        post_event_hours: inv.total_hours_formatted(start_time: event_end),
        post_event_credits: inv.total_credits_formatted(start_time: event_end),
        full_name: inv.profile.full_name,
        email: inv.profile.email,
        mailing_address: inv.profile.mailing_address.to_s
      sum[:total_seconds] += inv.total_seconds
      sum[:total_credits] += inv.total_credits
      sum[:pre_event_seconds] += inv.total_seconds(end_time: event_start)
      sum[:pre_event_credits] += inv.total_credits(end_time: event_start)
      sum[:event_seconds] +=
        inv.total_seconds(start_time: event_start, end_time: event_end)
      sum[:event_credits] +=
        inv.total_credits(start_time: event_start, end_time: event_end)
      sum[:post_event_seconds] += inv.total_seconds(start_time: event_end)
      sum[:post_event_credits] += inv.total_credits(start_time: event_end)
    end
    result.add_summary callsign: 'Total:',
      total_hours: format_seconds_as_hours_minutes(sum[:total_seconds]),
      total_credits: format('%.2f', sum[:total_credits]),
      pre_event_hours: format_seconds_as_hours_minutes(sum[:pre_event_seconds]),
      pre_event_credits: format('%.2f', sum[:pre_event_credits]),
      event_hours: format_seconds_as_hours_minutes(sum[:event_seconds]),
      event_credits: format('%.2f', sum[:event_credits]),
      post_event_hours:
        format_seconds_as_hours_minutes(sum[:post_event_seconds]),
      post_event_credits: format('%.2f', sum[:post_event_credits])
    result.entries.sort_by! {|e| e[:callsign].upcase}
    return Reporting::ReportResult.new result, result.entries.length,
      {event: event.name, teams: teams.map(&:name).to_sentence, statuses: @statuses.to_sentence}
  end
end
