class BirthdayReport
  def initialize(parameters)
    @month = parameters[:month]
    @event_id = parameters[:event_id]
  end

  def generate
    columns = [:name, :birthday, :status, :email]
    result = Reporting::KeyValueReport.new title: 'Birthdays',
      key_order: columns,
      key_labels: Hash[columns.map{|col| [col, col.to_s.capitalize]}]
    people = if @event_id
      Event.find(@event_id).people
    else
      Person.where status: [:vintage, :active, :inactive, :retired]
    end
    people.each do |p|
      p.birth_date.try do |birthday|
        if @month.nil? or @month == birthday.month
          result.add_entry name: p.callsign, birthday: birthday,
            status: p.status, email: p.email
        end
      end
    end
    result.entries.sort_by! do |entry|
      [entry[:birthday].month, entry[:birthday].day, entry[:name]]
    end
    return result, result.entries.length
  end
end
