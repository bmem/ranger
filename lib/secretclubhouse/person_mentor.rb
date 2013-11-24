module SecretClubhouse
  class PersonMentor < ActiveRecord::Base
    include BaseRecord
    self.table_name = 'person_mentor'
    target ::Mentor, :vote, :note

    def to_bmem_model
      mentor = super
      event = Event.find "burning-man-#{year}"
      mentor.event = event
      mentor_person = ::Person.find mentor_id
      mentor.involvement = mentor_person.involvements.where(event_id: event.id).first_or_create! do |inv|
        inv.name = mentor_person.display_name
        inv.personnel_status = mentor_person.status
        inv.involvement_status = 'confirmed'
      end
      mentee_person = ::Person.find person_id
      mentee_involvement = mentee_person.involvements.where(event_id: event.id).first_or_create! do |inv|
        inv.name = mentee_person.display_name
        inv.personnel_status = mentee_person.status
        inv.involvement_status = 'confirmed'
      end
      mentorship = event.mentorships.where(mentee_id: mentee_involvement.id).first_or_create! do |ms|
        ms.outcome = mentor.vote
        alpha = ::Position.find 'alpha'
        mentee_involvement.slots.each do |slot|
          if slot.position_id == alpha.id
            ms.shift = slot.shift
          end
        end
        if ms.shift.blank?
          mentee_involvement.work_logs.where(position_id: alpha.id) do |work|
            if work.shift.present?
              ms.shift = work.shift
            else
              event.slots.where(position_id: alpha.id) do |slot|
                if slot.shift.start_time < work.end_time and
                    slot.shift.end_time > work.start_time
                  ms.shift = slot.shift
                end
              end
            end
          end
        end
      end
      mentor.mentorship = mentorship
      mentor
    end

    def vote
      self.STATUS
    end

    def note
      notes
    end

    def year
      if mentor_year == 0
        p = ::Person.find person_id
        if p.display_name =~ /\b(\d{2})\b/
          return 2000 + $1.to_i
        end
        if p.involvements.any?
          return p.involvements.first.event.start_date.year
        end
      end
      mentor_year
    end

    def to_s
      "#{person_id} #{mentor_id} #{year}"
    end
  end
end
