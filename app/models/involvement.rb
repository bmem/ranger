class Involvement < ActiveRecord::Base
  STATUSES = [:planned, :confirmed, :bonked, :withdrawn]
  DETAIL_ATTRS = [
    :camp_location, :on_site_planned, :on_site_actual,
    :off_site_planned, :off_site_actual, :emergency_contact_info
  ]

  belongs_to :person
  belongs_to :event
  has_one :profile, through: :person
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

  def total_credits(options = {})
    options = options_with_defaults(options)
    filter_work_logs(options).reduce(0) do |sum, work|
      sum + work.credit_value(options[:start_time], options[:end_time])
    end
  end

  def total_credits_formatted(options = {})
    format('%.2f', total_credits(options))
  end

  def total_seconds(options = {})
    options = options_with_defaults(options)
    filter_work_logs(options).map do |w|
      w.seconds_overlap(options[:start_time], options[:end_time])
    end.reduce(0, :+)
  end

  def total_hours(options = {})
    total_seconds(options).to_f / 1.hour
  end

  def total_hours_formatted(options = {})
    hoursmins = (total_seconds(options) / 60).divmod(60)
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

  private
  def options_with_defaults(options = {})
    # 9999 is the maximal year for some databases
    options.reverse_merge start_time: Time.zone.local(1, 1, 1),
      end_time: Time.zone.local(9999, 12, 31)
  end

  def filter_work_logs(options = {})
    options = options_with_defaults(options)
    # Each Involvement usually has few Work Logs.  This may be called several
    # times, so optimize for a single query to load all logs rather than lots of
    # queries to load a range.
    logs = work_logs.find_all do |wl|
      wl.start_time <= options[:end_time] and
        wl.end_time_or_now >= options[:start_time]
    end
    if options[:position_ids].present?
      logs = logs.find_all {|wl| wl.position_id.in? options[:position_ids]}
    else
      # TODO convert Deep Freeze as an asset
      logs = logs.find_all {|wl| wl.position.slug != 'deep-freeze'}
    end
  end
end
