class HoursCreditsReport
  include TimeHelper

  def initialize(parameters)
    @event_id = parameters[:event_id]
    @team_ids = (parameters[:team_ids] || []).reject(&:blank?)
    @statuses = parameters[:involvement_statuses] || []
    @statuses = %w(confirmed) if @statuses.none?
    @hours_format = :decimal
    if %w(decimal hours_minutes).include? parameters[:hours_format].to_s
      @hours_format = parameters[:hours_format].to_sym
    end
  end

  def generate
    event = Event.find(@event_id)
    if @team_ids.present?
      positions = Position.where(team_id: @team_ids)
      position_ids = positions.map(&:id)
      teams = Team.find(@team_ids)
    end
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
    title = "Hours and Credits #{event}"
    title += " (#{teams.to_sentence})" if teams
    result = Reporting::KeyValueReport.new key_order: columns,
      key_labels: labels, title: title
    involvements = event.involvements.includes(:person).includes(:profile).
      where(involvement_status: @statuses)
    sum = Hash.new(0)
    involvements.each do |inv|
      sum[:total_seconds] += total_seconds =
        inv.total_seconds(position_ids: position_ids)
      # If teams were specified, only show people who worked those positions
      next if position_ids.present? and total_seconds == 0
      sum[:total_credits] += total_credits =
        inv.total_credits(position_ids: position_ids)
      sum[:pre_event_seconds] += pre_seconds =
        inv.total_seconds(end_time: event_start, position_ids: position_ids)
      sum[:pre_event_credits] += pre_credits =
        inv.total_credits(end_time: event_start, position_ids: position_ids)
      sum[:event_seconds] += event_seconds =
        inv.total_seconds(start_time: event_start, end_time: event_end, position_ids: position_ids)
      sum[:event_credits] += event_credits =
        inv.total_credits(start_time: event_start, end_time: event_end, position_ids: position_ids)
      sum[:post_event_seconds] += post_seconds =
        inv.total_seconds(start_time: event_end, position_ids: position_ids)
      sum[:post_event_credits] += post_credits =
        inv.total_credits(start_time: event_end, position_ids: position_ids)
      result.add_entry callsign: inv.name,
        status: inv.personnel_status,
        total_hours: format_seconds(total_seconds),
        total_credits: format_credits(total_credits),
        pre_event_hours: format_seconds(pre_seconds),
        pre_event_credits: format_credits(pre_credits),
        event_hours: format_seconds(event_seconds),
        event_credits: format_credits(event_credits),
        post_event_hours: format_seconds(post_seconds),
        post_event_credits: format_credits(post_credits),
        full_name: inv.profile.full_name,
        email: inv.profile.email,
        mailing_address: inv.profile.mailing_address.to_s
    end
    result.add_summary callsign: 'Total:',
      total_hours: format_seconds(sum[:total_seconds]),
      total_credits: format_credits(sum[:total_credits]),
      pre_event_hours: format_seconds(sum[:pre_event_seconds]),
      pre_event_credits: format_credits(sum[:pre_event_credits]),
      event_hours: format_seconds(sum[:event_seconds]),
      event_credits: format_credits(sum[:event_credits]),
      post_event_hours: format_seconds(sum[:post_event_seconds]),
      post_event_credits: format_credits(sum[:post_event_credits])
    result.entries.sort_by! {|e| e[:callsign].upcase}
    return Reporting::ReportResult.new result, result.entries.length,
      {event: event.name, teams: (teams || []).to_sentence,
        positions: (positions || []).to_sentence,
        statuses: @statuses.to_sentence, hours_format: @hours_format.to_s.humanize}
  end

  private
  def format_seconds(seconds)
    case @hours_format
    when :decimal then '%.2f' % (seconds.to_f / 1.hour)
    when :hours_minutes then format_seconds_as_hours_minutes(seconds)
    end
  end

  def format_credits(credits)
    '%.2f' % credits
  end
end
