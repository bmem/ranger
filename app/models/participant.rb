class Participant < ActiveRecord::Base
  STATUSES = [:planned, :confirmed, :bonked, :withdrawn]
  DETAIL_ATTRS = [
    :camp_location, :emergency_contact_info,
    :on_site_planned, :on_site_actual, :off_site_planned, :off_site_actual
  ]

  belongs_to :person
  belongs_to :event
  has_many :positions, :through => :person
  has_and_belongs_to_many :slots
  has_many :work_logs
  has_and_belongs_to_many :arts

  store :details, :accessors => DETAIL_ATTRS

  validates :name, :full_name, :participation_status, :personnel_status,
    :presence => true
  validates_uniqueness_of :person_id, :scope => :event_id,
    :message => 'is already participating in this event'
  validates_uniqueness_of :name, :scope => :event_id
  validates :participation_status, :inclusion =>
    { :in => STATUSES.map(&:to_s), :message => "is not a valid status" }
  validates :personnel_status, :inclusion =>
    { :in => Person::STATUSES.map(&:to_s), :message => "is not a valid status" }

  default_scope order('LOWER(name) ASC')

  before_validation do |p|
    if p.new_record?
      if p.person
        p.name = p.person.callsign if p.name.blank?
        p.full_name = p.person.full_name if p.full_name.blank?
        p.barcode = p.person.barcode if p.barcode.blank?
        p.personnel_status = p.person.status if p.personnel_status.blank?
        p.participation_status ||= 'planned'
      end
    end
  end

  def total_credits(start_t=nil, end_t=nil)
    work_logs.reduce(0) {|sum, work| sum + work.credit_value(start_t, end_t)}
  end

  def total_credits_formatted(start_t=nil, end_t=nil)
    format('%.2f', total_credits(start_t, end_t))
  end

  def total_seconds(start_time=Time.zone.local(1, 1, 1), end_time=Time.zone.local(10000, 1, 1))
    # TODO more sensibly convert Deep Freeze "positions"
    work_logs.find_all {|w| w.position.name != 'Deep Freeze'}.
      map {|w| w.seconds_overlap(start_time, end_time)}.reduce(0, :+)
  end

  def total_hours
    total_seconds.to_f / 1.hour
  end

  def total_hours_formatted
    hoursmins = (total_seconds / 60).divmod(60)
    format('%d:%02d', hoursmins[0], hoursmins[1].round)
  end
end
