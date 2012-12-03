class Slot < ActiveRecord::Base
  belongs_to :shift
  belongs_to :position
  has_and_belongs_to_many :participants

  validates :shift_id, :position_id, :presence => true
  validates :min_people, :max_people, :presence => true,
    :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validate :max_at_least_min, :if => 'max_people && min_people'

  def max_at_least_min
    if max_people > 0 and max_people < min_people
      errors[:max_people] << "must not be less than min people"
    end
  end
end
