class Person < ActiveRecord::Base
  include EmailHelper

  STATUSES = [:prospective, :alpha, :bonked, :active, :inactive,
    :retired, :uberbonked, :vintage, :deceased]
  SHIRT_SIZES = %w(XS S M L XL 2XL 3XL 4XL)
  DETAIL_ATTRS = [
    :mailing_address, :main_phone, :alt_phone, :birth_date, :shirt_size,
    :status_date, :callsign_approved, :has_personnel_note
  ]

  belongs_to :user
  has_many :participants
  has_many :events, :through => :participants
  has_and_belongs_to_many :positions

  store :details, :accessors => DETAIL_ATTRS

  validates :status, :callsign, :full_name, :presence => true
  validates :status, :inclusion => { :in => STATUSES.map(&:to_s),
    :message => "is not a valid status" }
  validates :callsign, :uniqueness => true, :length => { :in => 1..32 }
  validates :full_name, :length => { :in => 2..64 }
  validates :email, :uniqueness => true, :allow_blank => true,
    :format => EmailHelper::VALID_EMAIL

  acts_as_taggable_on :languages, :qualifications

  def self.find_by_email(email)
    self.where(:email => normalize_email(email))
  end

  def display_name
    callsign
  end

  def to_s
    display_name
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
