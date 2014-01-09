class BirthdayReport
  def initialize(parameters)
    @month = parameters[:month].presence.try {|m| m.to_i}
    @event_id = parameters[:event_id]
    @statuses = parameters[:statuses] || []
    @statuses = %w(vintage, active, inactive, retired) if @statuses.none?
  end

  def generate
    columns = [:name, :birthday, :status, :email]
    title = @month ? "#{Date::MONTHNAMES[@month]} Birthdays" : 'Birthdays'
    result = Reporting::KeyValueReport.new title: title,
      key_order: columns,
      key_labels: Hash[columns.map{|col| [col, col.to_s.capitalize]}]
    event = nil
    people = if @event_id.present?
      (event = Event.find(@event_id)).people.where(status: @statuses)
    else
      Person.where(status: @statuses)
    end
    people = people.includes(:profile)
    people.each do |p|
      p.profile and p.profile.birth_date.try do |birthday|
        if @month.blank? or @month == birthday.month
          result.add_entry name: p.callsign, birthday: birthday,
            status: p.status, email: p.profile.email
        end
      end
    end
    result.entries.sort_by! do |entry|
      [entry[:birthday].month, entry[:birthday].day, entry[:name]]
    end
    return Reporting::ReportResult.new result, result.entries.length,
      {event: event && event.name, month: @month && Date::MONTHNAMES[@month], statuses: @statuses.to_sentence}
  end
end
