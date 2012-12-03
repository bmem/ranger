class Event < ActiveRecord::Base
  has_many :shifts, :dependent => :destroy
  has_many :work_logs

  validates :name, :start_date, :end_date, :presence => true
  validates_with DateOrderValidator
  validates_with ReasonableDateValidator,
    :attributes => [:start_date, :end_date]

  def current?
    start_date <= Date.today && end_date >= Date.today
  end

  def completed?
    end_date < Date.today
  end

  def upcoming?
    start_date > Date.today
  end
end
