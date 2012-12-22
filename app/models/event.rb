class Event < ActiveRecord::Base
  TYPES = %w(BurningMan TrainingSeason GeneralEvent)

  attr_accessible :type, :name, :description, :signup_open, :start_date, :end_date, :linked_event_id

  has_many :shifts, :dependent => :destroy
  has_many :participants
  has_many :work_logs
  has_many :credit_schemes
  belongs_to :linked_event, :class_name => 'Event'

  class LinkTypeValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value.is_a? record.linked_event_class
        record.errors.add attribute, "linked event must be #{record.linked_event_class}"
      end
    end
  end

  class LinkMatchValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value.linked_event_id and value.linked_event_id != record.id
        record.errors.add attribute, "linked event already linked to a different event"
      end
    end
  end

  validates :name, :start_date, :end_date, :presence => true
  validates_with DateOrderValidator
  validates_with ReasonableDateValidator,
    :attributes => [:start_date, :end_date]
  validates :linked_event, :allow_nil => true,
    :link_type => true, :link_match => true

  after_save do |e|
    # When setting a linked event, link the other one to this one
    if e.linked_event_id and e.linked_event.linked_event_id.blank?
      e.linked_event.linked_event = e
      e.linked_event.save
    end
  end

  def <=>(other)
    if other.is_a?(Event)
      if start_date == other.start_date
        end_date <=> other.end_date
      else
        start_date <=> other.start_date
      end
    else
      nil
    end
  end

  def current?
    start_date <= Date.today && end_date >= Date.today
  end

  def completed?
    end_date < Date.today
  end

  def upcoming?
    start_date > Date.today
  end

  def linked_event_class
    self.class.linked_event_class
  end

  def self.linked_event_class
    Event
  end

  def self.inherited(child)
    child.instance_eval do
      def model_name
        Event.model_name
      end
    end
    super
  end
end
