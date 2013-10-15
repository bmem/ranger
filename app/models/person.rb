class Person < ActiveRecord::Base
  include EmailHelper

  STATUSES = [:prospective, :alpha, :bonked, :active, :inactive,
    :retired, :uberbonked, :vintage, :deceased]
  RANGER_STATUSES = [:active, :inactive, :retired, :vintage]
  SHIRT_SIZES = %w(XS S M L XL 2XL 3XL 4XL)
  SHIRT_STYLES = ['Ladies', 'Mens Regular', 'Mens Tall']
  DETAIL_ATTRS = [
    :mailing_address, :main_phone, :alt_phone, :birth_date, :shirt_size,
    :shirt_style, :gender, :status_date, :callsign_approved, :has_personnel_note
  ]

  belongs_to :user, :autosave => true
  has_one :profile, autosave: true, dependent: :destroy
  has_many :involvements
  has_many :events, :through => :involvements
  has_and_belongs_to_many :positions
  has_and_belongs_to_many :teams, join_table: :team_members
  has_and_belongs_to_many :managed_teams,
    join_table: :team_managers, class_name: 'Team'

  store :details, :accessors => DETAIL_ATTRS

  validates :status, :callsign, :full_name, :presence => true
  validates :status, :inclusion => { :in => STATUSES.map(&:to_s),
    :message => "is not a valid status" }
  validates :callsign, :uniqueness => true, :length => { :in => 1..32 }
  validates :full_name, :length => { :in => 2..64 }
  validates :email, :uniqueness => true, :allow_blank => true,
    :format => EmailHelper::VALID_EMAIL

  acts_as_taggable_on :languages, :qualifications

  self.per_page = 100

  default_scope { order('LOWER(callsign) ASC, LOWER(full_name) ASC') }
  scope :active_rangers, -> { where(status: [:active, :vintage]) }

  def self.find_by_email(email)
    self.where(:email => normalize_email(email))
  end

  def display_name
    callsign
  end

  def to_s
    display_name
  end

  def years_rangered
    @years_rangered ||= involvements.
      where(:involvement_status => 'confirmed').
      joins(:event).where('events.type' => 'BurningMan').
      count
  end

  before_validation do |p|
    if p.new_record?
      # assign default values
      p.callsign =
        "#{p.full_name} (new #{Date.today.year})" if p.callsign.blank?
      p.status = 'prospective' if p.status.blank?
      p.email = p.user.email if p.email.blank? && p.user
    end
    p.email = Person.normalize_email p.email
  end
end
