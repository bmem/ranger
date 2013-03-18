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
  HQ = Role.new(:hq, 'Eschelon HQ',
    'Edit people data, sign in/out, run reports')
  HQ_LEAD = Role.new(:hq_lead, 'Eschelon HQ Lead', 'Manage HQ operations')
  MENTOR = Role.new(:mentor, 'Mentor Short', 'Mentoring data entry and reports')
  TRAINER = Role.new(:trainer, 'Trainer', 'Training data entry and reports')
  TRAINER_LEAD = Role.new(:trainer_lead, 'Trainer Lead', 'Manage all trainings')
  VC = Role.new(:vc, 'Volunteer Coordinator', 'Volunteer intake and outreach')

  ALL = [ADMIN, HQ, HQ_LEAD, MENTOR, TRAINER, TRAINER_LEAD, VC].freeze
  ALL_SYM = ALL.map(&:to_sym).freeze
  BY_SYMBOL = ALL.index_by(&:to_sym).freeze

  private
  def new
    super
  end
end
