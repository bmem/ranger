class WorkLog < ActiveRecord::Base
  include TimeHelper
  belongs_to :involvement
  belongs_to :position
  belongs_to :event
  belongs_to :shift

  validates_presence_of :involvement, :position, :event, :start_time

  self.per_page = 100

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
    if start_t >= end_time_or_now || end_t <= start_time
      0
    else
      [end_t.to_i, end_time_or_now.to_i].min - [start_t.to_i, start_time.to_i].max
    end
  end

  def duration_seconds
    end_time.to_i - start_time.to_i
  end

  def hours_formatted
    distance_of_time_hours_minutes(start_time, end_time)
  end
end
