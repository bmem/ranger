class BurningMan < Event
  belongs_to :linked_event, :class_name => 'Training'

  def self.linked_event_class
    Training
  end
end
