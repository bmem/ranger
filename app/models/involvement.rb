class Involvement < ActiveRecord::Base
  STATUSES = [:planned, :confirmed, :bonked, :withdrawn].freeze
  DETAIL_ATTRS = [
    :camp_location, :on_site_planned, :on_site_actual,
    :off_site_planned, :off_site_actual, :emergency_contact_info
  ].freeze

  belongs_to :person
  belongs_to :event
  has_one :profile, through: :person
  has_many :positions, :through => :person
  has_many :attendees
  has_many :slots, through: :attendees
  has_many :work_logs
  has_many :asset_uses
  has_and_belongs_to_many :arts
  # this involvement is the mentee in self.mentorships
  has_many :mentorships, foreign_key: :mentee_id
  # this involvment is the mentor in self.mentors
  has_many :mentors

  # TODO make these actual attributes
  store :details, :accessors => DETAIL_ATTRS

  attr_accessible :name, :barcode, :involvement_status, :personnel_status,
    :on_site, *DETAIL_ATTRS

  acts_as_indexed fields: [:token_list]

  audited associated_with: :person
  has_associated_audits

  validates :name, :involvement_status, :personnel_status, :presence => true
  validates_uniqueness_of :person_id, :scope => :event_id,
    :message => 'is already participating in this event'
  validates_uniqueness_of :name, :scope => :event_id
  validates :involvement_status, :inclusion =>
    { :in => STATUSES.map(&:to_s), :message => "is not a valid status" }
  validates :personnel_status, :inclusion =>
    { :in => Person::STATUSES.map(&:to_s), :message => "is not a valid status" }

  default_scope order('LOWER(involvements.name) ASC')

  before_validation do |p|
    if p.new_record?
      if p.person
        p.name = p.person.display_name if p.name.blank?
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

  def to_tokens
    ([barcode] +
      name.to_tokens +
      (person || '').to_tokens
    ).reject(&:blank?).uniq
  end

  def token_list
    to_tokens.join(' ')
  end

  def to_typeahead_datum
    {
      id: id,
      value: name,
      tokens: to_tokens,
      full_name: person.full_name,
      barcode: barcode,
      status: personnel_status,
      involvement_status: involvement_status,
      event_name: event.name,
    }
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
