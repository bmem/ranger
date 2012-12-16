module ParticipantsHelper
  def participant_for_event_person(event_or_id, person_or_id)
    eventid = event_or_id.respond_to?(:id=) ? event_or_id.id : event_or_id
    personid = person_or_id.respond_to?(:id=) ? person_or_id.id : person_or_id
    Participant.find_by_event_id_and_person_id(eventid, personid)
  end
end
