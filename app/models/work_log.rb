class WorkLog < ActiveRecord::Base
  include TimeHelper
  belongs_to :involvement
  belongs_to :position
  belongs_to :event
  belongs_to :shift
  # TODO this one really needs strong parameters.
  attr_accessible :involvement_id, :position_id, :shift_id, :event_id,
    :start_time, :end_time, :note

  audited associated_with: :involvement

  validates_presence_of :involvement, :position, :event, :start_time
  validates :audit_comment, presence: true, on: :update

  self.per_page = 100

  def self.during(start_time, end_time)
    where('start_time <= ? AND (end_time >= ? OR end_time IS NULL)',
      end_time, start_time)
  end

  def end_time_or_now
    end_time || Time.zone.now
  end

  def scheme
    CreditScheme.find(:first, :joins => :positions, :conditions => {:event_id => event_id, 'credit_schemes_positions.position_id' => position_id})
  end

  def credit_value(start_t=nil, end_t=nil)
    first = start_time
    last = end_time_or_now
    first = start_t if start_t and start_t > start_time
    last = end_t if end_t and end_t < end_time_or_now
    return 0 if first >= end_time_or_now or last <= start_time
    scheme.try {|s| s.credit_value(first, last)} || 0
  end

  def credit_value_formatted
    format('%.2f', credit_value)
  end

  def credit_value_explained
    if scheme
      scheme.explained_credit_values(start_time, end_time_or_now).to_sentence
    else
      nil
    end
  end

  def seconds_overlap(start_t, end_t)
    overlap_seconds(start_time..end_time_or_now, start_t..end_t)
  end

  def duration_seconds
    end_time.to_i - start_time.to_i
  end

  def hours_formatted
    distance_of_time_hours_minutes(start_time, end_time)
  end

  def guess_shift!
    unless shift_id
      wlrange = start_time..end_time
      mappct = Proc.new do |shift|
        pct = overlap_seconds(wlrange, (shift.start_time..shift.end_time)) /
          shift.duration_seconds
        [pct, shift]
      end
      personal = involvement.shifts.with_positions(position_id).
        overlapping(wlrange).map(&mappct).sort
      if personal.any? and personal.last.first > 0.5
        self.shift = personal.last.second
      else
        general = event.shifts.with_positions(position_id).
          overlapping(wlrange).map(&mappct).sort
        a = general.any? ? general.last : [0, nil]
        b = personal.any? ? personal.last : [0, nil]
        self.shift = [a, b].max.last
      end
    end
    self.shift
  end
end
