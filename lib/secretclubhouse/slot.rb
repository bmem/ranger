module SecretClubhouse
  class Slot < ActiveRecord::Base
    include BaseRecord
    include TimeZoneAdjusting
    self.table_name = 'slot'
    self.target ::Slot, :position_id, :max_people, :min_people
    attr_accessor :event

    belongs_to :position
    has_and_belongs_to_many :people, :join_table => 'person_slot'

    scope :with_position, lambda {|p| where('position_id IN (?)', p)}
    scope :in_year, lambda {|year| where('YEAR(begins) = ?', year)}

    def to_bmem_model
      s = super
      people.each do |p|
        person = ::Person.find(p.id)
        involvement = person.involvements.find_by_event_id(event.id)
        unless involvement
          # if they'd worked any shifts, they would already have a record
          # so create a withdrawn involvement
          # TODO set personnel_status to alpha if they weren't a ranger
          # TODO check if they completed training
          status = event.is_a?(TrainingSeason) ? 'confirmed' : 'withdrawn'
          involvement = person.involvements.create :event => event,
            :name => p.callsign, :personnel_status => p.status,
            :involvement_status => status
        end
        s.involvements << involvement
      end
      s
    end

    def max_people
      max
    end

    def min_people
      min
    end

    def start_time
      adjust_time begins
    end

    def end_time
      adjust_time ends
    end

    def to_s
      "#{position.title} #{description} #{begins}"
    end
  end
end
