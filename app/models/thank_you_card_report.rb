class ThankYouCardReport
  def initialize(parameters)
    @event_id = parameters[:event_id]
  end

  def generate
    columns = [:team, :first, :last, :callsign, :email,
      :address1, :address2, :city, :state, :postcode, :country]
    labels = ['Team', 'First', 'Last', 'AKA/Paya Name', 'Email Address',
      'Address', 'Address 2', 'City', 'State', 'Zip', 'Country']
    result = Reporting::KeyValueReport.new title: 'Thank You Cards',
      key_order: columns,
      key_labels: labels
    involvements = Event.find(@event_id).involvements.includes(:person).
      where(involvement_status: 'confirmed',
        personnel_status: Person::RANGER_STATUSES)
    involvements.map(&:person).each do |person|
      p = person.profile
      name = p.split_name
      a = p.mailing_address || MailingAddress.new
      lines = [a.extra_address, a.street_address, a.post_office_box].
        find_all(&:present?)
      line1 = line2 = nil
      case lines.length
      when 3 then line1, line2 = lines[1..2]
      when 2 then line1, line2 = lines
      when 1 then line1 = lines[0]
      end
      result.add_entry team: 'Rangers', first: name[0], last: name[1],
        callsign: person.callsign, email: p.email, address1: line1,
        address2: line2, city: a.locality, state: a.region,
        postcode: a.postal_code, country: a.country_name
    end
    result.entries.sort_by! {|e| e[:callsign].upcase}
    return result, result.entries.length
  end
end
