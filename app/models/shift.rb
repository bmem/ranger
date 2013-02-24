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

  def create_slots_from_template(shift_template)
    shift_template.slot_templates.map do |t|
      slots.create :shift => self, :position_id => t.position_id, :min_people => t.min_people, :max_people => t.max_people
    end
  end

  def merge_from_template!(shift_template, date = nil)
    t = shift_template
    default_date = event ? event.start_date : Time.zone.now
    d = case date
        when nil then default_date
        when /^\s*$/ then default_date
        when String then Time.zone.parse(date) || default_date
        when Fixnum then Time.zone.at(date)
        else date
        end
    self.name = t.name if t.name.present?
    self.description = t.description if t.description.present?
    self.start_time =
      Time.zone.local(d.year, d.month, d.day, t.start_hour, t.start_minute)
    self.end_time =
      Time.zone.local(d.year, d.month, d.day, t.end_hour, t.end_minute)
    self.end_time += 1.day if end_time < start_time
  end

  def to_s_with_date
    starts = "#{I18n.l start_time, :format => :short}"
    ends = "#{I18n.l end_time, :format => :short}"
    "#{name} #{starts} - #{ends}"
  end
end
