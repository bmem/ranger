class Role
  attr_reader :sym, :name, :description

  def self.[](role)
    BY_SYMBOL[role.to_sym]
  end

  def self.valid?(role)
    role.present? && Role[role]
  end

  def initialize(sym, name, description)
    @sym = sym
    @name = name
    @description = description
  end

  def to_s
    name
  end

  def to_sym
    @sym
  end

  ADMIN = Role.new(:admin, 'System Administrator',
    'Access to all data and functionality')
  HQ = Role.new(:hq, 'Echelon HQ',
    'Edit people data, sign in/out, run reports')
  HQ_LEAD = Role.new(:hq_lead, 'Echelon HQ Lead', 'Manage HQ operations')
  LAMINATES = Role.new(:laminates, 'Laminates', 'Organize and print IDs')
  MENTOR = Role.new(:mentor, 'Mentor Short', 'Mentoring data entry and reports')
  OPERATOR = Role.new(:operator, 'Operator',
    'See data in support of incident logging')
  PERSONNEL = Role.new(:personnel, 'Personnel Manager', 'Manage people')
  SHIFT_LEAD = Role.new(:shift_lead, 'Shift Lead',
    'View people, schedules, and reports')
  TRAINER = Role.new(:trainer, 'Trainer', 'Training data entry and reports')
  TRAINER_LEAD = Role.new(:trainer_lead, 'Trainer Lead', 'Manage all trainings')
  VC = Role.new(:vc, 'Volunteer Coordinator', 'Volunteer intake and outreach')
  VEHICLE_LEAD = Role.new(:vehicle_lead, 'Vehicle lead',
    'Manage the motor pool')

  ALL = [ADMIN, HQ, HQ_LEAD, LAMINATES, MENTOR, OPERATOR, PERSONNEL, SHIFT_LEAD,
    TRAINER, TRAINER_LEAD, VC, VEHICLE_LEAD].freeze
  ALL_SYM = ALL.map(&:to_sym).freeze
  BY_SYMBOL = ALL.index_by(&:to_sym).freeze

  private
  def new
    super
  end
end
