class Key < Asset
  BUILDING = 'Building'
  DEEP_FREEZE = 'Deep Freeze'
  DESIGNATIONS = [BUILDING, DEEP_FREEZE].freeze

  validates :designation, inclusion: { in: DESIGNATIONS }

  def possible_designations
    DESIGNATIONS
  end
end
