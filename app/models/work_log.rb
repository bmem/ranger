class WorkLog < ActiveRecord::Base
  belongs_to :participant
  belongs_to :position
  belongs_to :event
  belongs_to :shift

  validates_presence_of :participant, :position, :event, :start_time

  def scheme
  #CreditScheme.joinwhere(:event_id => event.id).to_a.find do |cs|
      #position_id.in? cs.position_ids
    #end
    CreditScheme.find(:first, :joins => :positions, :conditions => {:event_id => event_id, 'credit_schemes_positions.position_id' => position_id})
  end

  def credit_value(start_t=nil, end_t=nil)
    first = start_time
    last = end_time
    first = start_t if start_t and start_t > start_time
    last = end_t if end_t and end_t < end_time
    return 0 if first >= end_time or last <= start_time
    scheme.try {|s| s.credit_value(first, last)} || 0
  end

  def credit_value_formatted
    format('%.2f', credit_value)
  end

  def credit_value_explained
    scheme.try {|s| s.explained_credit_values(start_time, end_time).to_sentence}
  end

  def seconds_overlap(start_t, end_t)
    if start_t >= end_time || end_t <= start_time
      0
    else
      [end_t.to_i, end_time.to_i].min - [start_t.to_i, start_time.to_i].max
    end
  end

  def duration_seconds
    end_time.to_i - start_time.to_i
  end

  def hours_formatted
    secs = end_time.utc.to_time - start_time.utc.to_time
    hoursmins = (secs / 60).divmod(60)
    format('%d:%02d', hoursmins[0], hoursmins[1].round)
  end
end
