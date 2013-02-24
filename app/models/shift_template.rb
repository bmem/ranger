class ShiftTemplate < ActiveRecord::Base
  attr_accessible :description, :end_hour, :end_minute, :event_type, :name, :start_hour, :start_minute, :title

  has_many :slot_templates, :dependent => :destroy

  validates :title, :presence => true, :uniqueness => true
  validates_inclusion_of :start_hour, :end_hour, :in => 0..23
  validates_inclusion_of :start_minute, :end_minute, :in => 0..60

  default_scope includes(:slot_templates)
  default_scope order(:title)

  def self.for_event_type(event_or_type)
    case event_or_type
    when nil then all
    when Event then where(:event_type => event_or_type.class.to_s)
    else where(:event_type => event_or_type.to_s)
    end
  end
end
