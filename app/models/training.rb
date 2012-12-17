class Training < Event
  belongs_to :linked_event, :class_name => 'BurningMan'

  def self.linked_event_class
    BurningMan
  end
end
