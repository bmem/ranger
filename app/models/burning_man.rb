class BurningMan < Event
  belongs_to :linked_event, :class_name => 'TrainingSeason'

  def self.linked_event_class
    TrainingSeason
  end
end
