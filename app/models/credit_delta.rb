class CreditDelta < ActiveRecord::Base
  belongs_to :credit_scheme
  has_one :event, :through => :credit_scheme

  attr_accessible :end_time, :hourly_rate, :name, :start_time

  validates_presence_of :name, :hourly_rate, :start_time, :end_time
  validates_with DateOrderValidator, :start => :start_time, :end => :end_time
  validates_with ReasonableDateValidator,
    :attributes => [:start_time, :end_time]

  def parent_records
    [event, credit_scheme]
  end
end
