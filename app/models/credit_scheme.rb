class CreditScheme < ActiveRecord::Base
  belongs_to :event
  has_many :credit_deltas, :dependent => :destroy
  has_and_belongs_to_many :positions
  attr_accessible :base_hourly_rate, :description, :name, :position_ids

  validates_presence_of :name, :base_hourly_rate

  def credit_value(start_time, end_time)
    total_hours = hours(end_time.to_i - start_time.to_i)
    credit_deltas.reduce(base_hourly_rate * total_hours) do |sum, d|
      sum + d.hourly_rate *
        hours(sec_overlap(d.start_time, d.end_time, start_time, end_time))
    end
  end

  def explained_credit_values(start_time, end_time)
    total_hours = hours(end_time.to_i - start_time.to_i)
    exp = ["Base rate: #{format('%.2f', base_hourly_rate * total_hours)}"]
    credit_deltas.each do |d|
      h = hours(sec_overlap(d.start_time, d.end_time, start_time, end_time))
      exp << "#{d.name}: #{format('%.2f', d.hourly_rate * h)}" if h > 0
    end
    exp
  end

  private
  def sec_overlap(start1, end1, start2, end2)
    return 0 if start1 >= end2 or end1 <= start2
    return [end1.to_i, end2.to_i].min - [start1.to_i, start2.to_i].max
  end

  def hours(seconds)
    seconds / 60.0 / 60.0
  end
end
