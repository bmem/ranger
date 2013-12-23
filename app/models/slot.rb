class Slot < ActiveRecord::Base
  belongs_to :shift
  belongs_to :position
  has_and_belongs_to_many :involvements
  has_one :event, :through => :shift

  validates :shift_id, :position_id, :presence => true
  validates :min_people, :max_people, :presence => true,
    :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validate :max_at_least_min, :if => 'max_people && min_people'

  # select * so the results aren't readonly
  scope :with_shift, select('slots.*').joins(:shift).order('shifts.start_time')

  self.per_page = 100

  def parent_records
    [event, shift]
  end

  def credit_scheme
    event.credit_schemes.joins(:positions).
      where('credit_schemes_positions.position_id' => position_id).first
  end

  def credit_value
    credit_scheme.try {|s| s.credit_value shift.start_time, shift.end_time} || 0
  end

  def credit_value_formatted
    format('%.2f', credit_value)
  end

  def full?
    max_people > 0 && involvements.count >= max_people
  end

  def in_need?
    min_people > 0 && involvements.count < min_people
  end

  def to_title
    position && position.to_title
  end

  def max_at_least_min
    if max_people > 0 and max_people < min_people
      errors[:max_people] << "must not be less than min people"
    end
  end
end
