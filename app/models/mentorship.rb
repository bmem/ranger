class Mentorship < ActiveRecord::Base
  OUTCOMES = %w(pending pass bonk).freeze

  belongs_to :event
  belongs_to :shift
  belongs_to :mentee, class_name: 'Involvement'
  has_many :mentors, dependent: :destroy
  attr_accessible :note, :outcome, :shift_id

  validates :outcome, inclusion: {in: OUTCOMES}
  validate do
    errors.add(:mentee, 'Event mismatch') unless event_id == mentee.event_id
    errors.add(:shift, 'Shift must be from same event') unless
      shift.blank? or shift.event_id == event_id
  end

  def display_name
    mentee.name
  end
end
