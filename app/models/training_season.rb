class TrainingSeason < Event
  belongs_to :linked_event, :class_name => 'BurningMan'
  has_many :trainings, :dependent => :destroy

  def self.linked_event_class
    BurningMan
  end
end
