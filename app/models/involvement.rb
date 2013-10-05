class Involvement < ActiveRecord::Base
  STATUSES = [:planned, :confirmed, :bonked, :withdrawn]
  DETAIL_ATTRS = [
    :camp_location, :on_site_planned, :on_site_actual,
    :off_site_planned, :off_site_actual, :emergency_contact_info
  ]

  belongs_to :person
  belongs_to :event
  has_many :positions, :through => :person
  has_and_belongs_to_many :slots
  has_many :work_logs
  has_many :asset_uses
  has_and_belongs_to_many :arts

  store :details, :accessors => DETAIL_ATTRS

  validates :name, :involvement_status, :personnel_status, :presence => true
  validates_uniqueness_of :person_id, :scope => :event_id,
    :message => 'is already participating in this event'
  validates_uniqueness_of :name, :scope => :event_id
  validates :involvement_status, :inclusion =>
    { :in => STATUSES.map(&:to_s), :message => "is not a valid status" }
  validates :personnel_status, :inclusion =>
    { :in => Person::STATUSES.map(&:to_s), :message => "is not a valid status" }

  default_scope order('LOWER(name) ASC')

  before_validation do |p|
    if p.new_record?
      if p.person
        p.name = p.person.callsign if p.name.blank?
        p.barcode = p.person.barcode if p.barcode.blank?
        p.personnel_status = p.person.status if p.personnel_status.blank?
        p.involvement_status ||= 'planned'
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

  def prior_years_rangered
    @prior_years_rangered ||= Involvement.
      where(:person_id => person_id).
      where(:involvement_status => 'confirmed').
      joins(:event).
      where('events.type' => 'BurningMan').
      where('events.start_date < ?', event.start_date).
      count
  end
end
