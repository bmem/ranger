class Role
  attr_reader :sym, :name, :description

  def self.[](role)
    BY_SYMBOL[role.to_sym]
  end

  def self.valid?(role)
    role.present? && Role[role]
  end

  def initialize(sym, name, description, managed_by_syms)
    @sym = sym
    @name = name
    @description = description
    @managed_by_syms = managed_by_syms.freeze
  end

  def <=>(other)
    name <=> other.name
  end

  def to_s
    name
  end

  def to_sym
    @sym
  end

  def managed_by_roles
    @managed_by_syms.map {|sym| BY_SYMBOL[sym]}
  end

  # TODO Figure out the right limited role for operations management (e.g.,
  # granting SHIFT_LEAD role, creating shifts).  OPERATIONS_LEAD?
  # TODO Should SHIFT_LEAD and OPERATOR merge to a single SHIFT_COMMAND?
  # TODO Is a COUNCIL role needed, independent of PERSONNEL?
  ADMIN = Role.new(:admin, 'System Administrator',
    'Access to all data and functionality', [:admin, :personnel])
  HQ = Role.new(:hq, 'Echelon HQ',
    'Edit people data, sign in/out, run reports',
    [:admin, :personnel, :hq_lead])
  HQ_LEAD = Role.new(:hq_lead, 'Echelon HQ Lead', 'Manage HQ operations',
    [:admin, :personnel, :hq_lead])
  LAMINATES = Role.new(:laminates, 'Laminates', 'Organize and print IDs',
    [:admin, :personnel, :hq_lead, :laminates])
  MENTOR = Role.new(:mentor, 'Mentor Lead', 'Mentoring data entry and reports',
    [:admin, :personnel, :mentor])
  OPERATOR = Role.new(:operator, 'Operator',
    'See data in support of incident logging', [:admin, :personnel, :hq_lead])
  PERSONNEL = Role.new(:personnel, 'Personnel Manager', 'Manage people',
    [:admin, :personnel])
  SHIFT_LEAD = Role.new(:shift_lead, 'Shift Lead',
    'View people, schedules, and reports', [:admin, :personnel, :hq_lead])
  TRAINER = Role.new(:trainer, 'Trainer', 'Training data entry and reports',
    [:admin, :personnel, :trainer_lead])
  TRAINER_LEAD = Role.new(:trainer_lead, 'Trainer Lead', 'Manage all trainings',
    [:admin, :personnel, :trainer_lead])
  VC = Role.new(:vc, 'Volunteer Coordinator', 'Volunteer intake and outreach',
    [:admin, :vc])
  VEHICLE_LEAD = Role.new(:vehicle_lead, 'Vehicle Lead',
    'Manage the motor pool', [:admin, :personnel, :vehicle_lead])

  ALL = [ADMIN, HQ, HQ_LEAD, LAMINATES, MENTOR, OPERATOR, PERSONNEL, SHIFT_LEAD,
    TRAINER, TRAINER_LEAD, VC, VEHICLE_LEAD].freeze
  ALL_SYM = ALL.map(&:to_sym).freeze
  BY_SYMBOL = ALL.index_by(&:to_sym).freeze
  BY_MANAGING_ROLE =
    Hash[ALL.inject(Hash.new {|h, k| h[k] = []}) do |hash, role|
      role.managed_by_roles.each {|m| hash[m] << role}
      hash
    end].freeze

  private
  def new
    super
  end
end
