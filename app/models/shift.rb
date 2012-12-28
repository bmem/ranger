class Shift < ActiveRecord::Base
  belongs_to :event
  has_many :slots, :dependent => :destroy
  has_many :work_logs
  has_one :training, :dependent => :destroy # iff event type is TrainingSeason
  accepts_nested_attributes_for :training

  validates :name, :start_time, :end_time, :event, :presence => true
  validates_presence_of :training, :if => Proc.new {|shift| shift.event.is_a? TrainingSeason}
  validates_with DateOrderValidator, :start => :start_time, :end => :end_time
  validates_with ReasonableDateValidator,
    :attributes => [:start_time, :end_time]
  # TODO validate start/end overlap with event's start/end?

  before_validation do |shift|
    if shift.event.is_a? TrainingSeason and shift.training.blank?
      shift.build_training
      shift.training.shift = shift
    end
  end

  def to_s_with_date
    starts = "#{I18n.l start_time, :format => :short}"
    ends = "#{I18n.l end_time, :format => :short}"
    "#{name} #{starts} - #{ends}"
  end
end
