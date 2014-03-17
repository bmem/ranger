module SecretClubhouse
  class Ticket < ActiveRecord::Base
    include BaseRecord
    self.table_name = 'ticket'
    target ::EventRadioAuthorization

    belongs_to :person

    def to_bmem_model
      a = super
      if eligibility == 'gift'
        a.event = ::Event.find("burning-man-#{year}")
        involvements = a.event.involvements.where(person_id: person_id)
        if involvements.present?
          a.involvement = involvements.first
          a
        else
          nil
        end
      else
        nil
      end
    end

    def to_s
      "#{year} #{person_id} #{eligibility}"
    end
  end
end
