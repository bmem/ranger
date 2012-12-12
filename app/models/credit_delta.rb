class CreditDelta < ActiveRecord::Base
  belongs_to :credit_scheme
  attr_accessible :end_time, :hourly_rate, :name, :start_time

  validates_presence_of :name, :hourly_rate, :start_time, :end_time
  validates_with DateOrderValidator, :start => :start_time, :end => :end_time
  validates_with ReasonableDateValidator,
    :attributes => [:start_time, :end_time]

  def event
    credit_scheme.event
  end

  def event_id
    credit_scheme.event_id
  end
end
