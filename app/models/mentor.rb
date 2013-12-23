class Mentor < ActiveRecord::Base
  belongs_to :event
  belongs_to :mentorship
  belongs_to :involvement
  has_one :shift, through: :mentorship
  has_one :mentee, through: :mentorship, class_name: 'Involvement'
  attr_accessible :involvement_id, :note, :vote

  validates_uniqueness_of :involvement_id, scope: :mentorship_id
  validates :vote, inclusion: {in: Mentorship::OUTCOMES}
  validate do
    errors.add(:mentorship, 'Mentorship event mismatch') unless
      event_id == mentorship.event_id
    errors.add(:involvement, 'Involvement event mismatch') unless
      event_id == involvement.event_id
  end

  def display_name
    involvement.name
  end
end
