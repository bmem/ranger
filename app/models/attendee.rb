class Attendee < ActiveRecord::Base
  STATUSES = %w(planned confirmed noshow).freeze

  belongs_to :slot, counter_cache: true
  belongs_to :involvement
  has_one :event, through: :involvement
  has_one :shift, through: :slot
  has_one :position, through: :slot
  attr_accessible :status

  audited associated_with: :involvement

  validates :slot_id, :involvement_id, presence: true
  validates :status, inclusion: STATUSES
  validate :slot_involvement_same_event

  self.per_page = 100

  def parent_records
    [event, slot]
  end

  def event
    (involvement || slot).try {|x| x.event}
  end

  def event_id
    (involvement || slot).try {|x| x.event_id}
  end

  def to_title
    slot && involvement && "#{involvement} in #{slot}"
  end

  def slot_involvement_same_event
    if slot && involvement && slot.event.id != involvement.event_id
      errors[:involvement_id] << 'involvement and slot must be from same event'
    end
  end
end
