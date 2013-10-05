class Radio < Asset
  EVENT = 'Event Radio'
  SHIFT = 'Shift Radio'
  DESIGNATIONS = [EVENT, SHIFT].freeze
  EXTRAS = ['Shoulder Mic', 'Headset', 'Helicopter Headset', 'Sur Kit'].freeze

  validates :designation, inclusion: { in: DESIGNATIONS }

  def possible_designations
    DESIGNATIONS
  end

  def possible_extras
    EXTRAS
  end
end
