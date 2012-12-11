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

  def credit_value
    scheme.try {|s| s.credit_value(start_time, end_time)} || 0
  end

  def credit_value_formatted
    format('%.2f', credit_value)
  end

  def credit_value_explained
    scheme.try {|s| s.explained_credit_values(start_time, end_time).to_sentence}
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
