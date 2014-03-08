class Event < ActiveRecord::Base
  include FriendlyId
  TYPES = %w(BurningMan TrainingSeason GeneralEvent)

  friendly_id :name, use: :slugged

  attr_accessible :type, :name, :description, :signup_open, :start_date, :end_date, :linked_event_id

  has_many :shifts, :dependent => :destroy
  has_many :slots, :through => :shifts
  has_many :involvements
  has_many :attendees, through: :involvements
  has_many :people, through: :involvements
  has_many :work_logs
  has_many :credit_schemes
  has_many :assets
  has_many :asset_uses
  has_many :mentorships
  has_many :mentors
  belongs_to :linked_event, :class_name => 'Event'

  audited
  has_associated_audits

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

  default_scope order('start_date DESC, end_date DESC')
  scope :signup_open, where(:signup_open => true)
  scope :upcoming, lambda {where('start_date > ?', Date.today)}
  scope :current, lambda {where('? BETWEEN start_date AND end_date', Date.today)}
  scope :completed, lambda {where('end_date < ?', Date.today)}

  after_save do |e|
    # When setting a linked event, link the other one to this one
    if e.linked_event_id and e.linked_event.linked_event_id.blank?
      e.linked_event.linked_event_id = e.id
      e.linked_event.save
    end
  end

  def <=>(other)
    if other.is_a?(Event)
      if start_date == other.start_date
        other.end_date <=> end_date
      else
        other.start_date <=> start_date
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
