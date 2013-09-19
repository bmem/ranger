class Radio < Asset
  EVENT = 'Event Radio'
  SHIFT = 'Shift Radio'
  DESIGNATIONS = [EVENT, SHIFT].freeze

  validates :designation, inclusion: { in: DESIGNATIONS }

  def possible_designations
    DESIGNATIONS
  end
end
