module InvolvementsHelper
  def involvement_for_event_person(event_or_id, person_or_id)
    if event_or_id.friendly_id?
      event_or_id = Event.find(event_or_id)
    end
    if not event_or_id or not person_or_id
      nil
    elsif person_or_id.respond_to?(:involvements)
      person_or_id.involvements.where(event_id: event_or_id).first
    elsif event_or_id.respond_to?(:involvements)
      event_or_id.involvements.where(person_id: person_or_id).first
    else
      Involvement.
        where(event_id: event_or_id).where(person_id: person_or_id).first
    end
  end
end
