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
  MENTOR = Role.new(:mentor, 'Mentor Short', 'Mentoring data entry and reports')
  TRAINER = Role.new(:trainer, 'Trainer', 'Training data entry and reports')

  ALL = [ADMIN, HQ, MENTOR, TRAINER].freeze
  ALL_SYM = ALL.map(&:to_sym).freeze
  BY_SYMBOL = ALL.index_by(&:to_sym).freeze

  private
  def new
    super
  end
end
