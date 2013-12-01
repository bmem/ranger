class Person < ActiveRecord::Base
  include EmailHelper

  STATUSES = [:active, :vintage, :inactive, :retired,
    :prospective, :alpha, :bonked, :uberbonked, :deceased]
  RANGER_STATUSES = [:active, :inactive, :retired, :vintage]
  SHIRT_SIZES = %w(XS S M L XL 2XL 3XL 4XL)
  SHIRT_STYLES = ['Ladies', 'Mens Regular', 'Mens Tall']
  DETAIL_ATTRS = [:callsign_approved, :has_personnel_note, :status_date]

  belongs_to :user, :autosave => true
  has_one :profile, autosave: true, dependent: :destroy
  has_many :involvements
  has_many :events, :through => :involvements
  has_many :callsign_assignments, autosave: true
  has_many :callsigns, through: :callsign_assignments
  has_and_belongs_to_many :positions
  has_and_belongs_to_many :teams, join_table: :team_members
  has_and_belongs_to_many :managed_teams,
    join_table: :team_managers, class_name: 'Team'

  store :details, :accessors => DETAIL_ATTRS

  # TODO add an if: Proc that excludes uninteresting Person records
  acts_as_indexed fields: [:token_list]

  #validates :status, :callsign, :full_name, :presence => true
  validates :status, :display_name, :full_name, :presence => true
  validates :status, :inclusion => { :in => STATUSES.map(&:to_s),
    :message => "is not a valid status" }
  #validates :callsign, :uniqueness => true, :length => { :in => 1..32 }
  validates :display_name, :uniqueness => true, :length => { :in => 1..32 }
  validates :full_name, :length => { :in => 2..64 }
  validates :email, :uniqueness => true, :allow_blank => true,
    :format => EmailHelper::VALID_EMAIL

  acts_as_taggable_on :languages, :qualifications

  self.per_page = 100

  #default_scope { order('LOWER(callsign) ASC, LOWER(full_name) ASC') }
  default_scope { order('LOWER(display_name) ASC, LOWER(full_name) ASC') }
  scope :active_rangers, -> { where(status: [:active, :vintage]) }

  def self.find_by_email(email)
    self.where(:email => normalize_email(email))
  end

  def to_s
    display_name || full_name
  end

  def callsign
    return @callsign if @callsign
    assignment = callsign_assignments.current.primary.first
    assignment ||= callsign_assignments.current.first
    assignment && @callsign = assignment.callsign
  end

  def callsign_status
    callsign ? callsign.status : ''
  end

  def years_rangered
    @years_rangered ||= involvements.
      where(:involvement_status => 'confirmed').
      joins(:event).where('events.type' => 'BurningMan').
      count
  end

  def update_display_name!
    if callsign
      self.display_name = callsign.name
    elsif display_name.blank? and full_name.present?
      target = full_name
      disambiguate = 0
      while (Person.where('LOWER(display_name) = ?', target).count > 0) do
        disambiguate += 1
        append = " (#{disambiguate})"
        target = full_name.slice(0, 32 - append.length) + append
      end
      self.display_name = target
    end
  end

  def to_tokens
    ([barcode] +
      display_name.to_tokens +
      full_name.to_tokens +
      ((email || '')).to_tokens +
      callsigns.map {|c| c.name.to_tokens}.flatten
    ).reject(&:blank?).uniq
  end

  def token_list
    to_tokens.join(' ')
  end

  def to_typeahead_datum
    {
      id: id,
      value: display_name,
      tokens: to_tokens,
      full_name: full_name,
      barcode: barcode,
      status: status,
    }
  end

  before_validation do |p|
    p.update_display_name!
    if p.new_record?
      # assign default values
      #p.callsign =
      #  "#{p.full_name} (new #{Date.today.year})" if p.callsign.blank?
      p.status = 'prospective' if p.status.blank?
      p.email = p.user.email if p.email.blank? && p.user
    end
    p.email = Person.normalize_email p.email
  end
end
