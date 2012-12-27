class Shift < ActiveRecord::Base
  belongs_to :event
  has_many :slots, :dependent => :destroy
  has_many :work_logs
  has_one :training, :dependent => :destroy # iff event type is TrainingSeason

  validates :name, :start_time, :end_time, :event, :presence => true
  validates_with DateOrderValidator, :start => :start_time, :end => :end_time
  validates_with ReasonableDateValidator,
    :attributes => [:start_time, :end_time]
  # TODO validate start/end overlap with event's start/end?

  def to_s_with_date
    starts = "#{I18n.l start_time, :format => :short}"
    ends = "#{I18n.l end_time, :format => :short}"
    "#{name} #{starts} - #{ends}"
  end
end
