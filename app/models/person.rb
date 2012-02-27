class Person < ActiveRecord::Base
  STATUSES = [:prospective, :alpha, :bonked, :active, :inactive,
    :retired, :uberbonked, :vintage, :deceased]
  SHIRT_SIZES = %w(XS S M L XL 2XL 3XL 4XL)
  DETAIL_ATTRS = [
    :email, :mailing_address, :main_phone, :alt_phone, :birth_date, :shirt_size,
    :camp_location, :emergency_contact, :status_date, :callsign_approved,
    :asset_authorized, :vehicle_paperwork, :vehicle_blacklisted,
    :has_personnel_note
  ]

  belongs_to :user

  store :details, :accessors => DETAIL_ATTRS

  validates :status, :callsign, :full_name, :presence => true
  validates :status, :inclusion => { :in => STATUSES.map(&:to_s),
    :message => "is not a valid status" }
  validates :callsign, :uniqueness => true, :length => { :in => 1..32 }
  validates :full_name, :length => { :in => 2..64 }

  def display_name
    callsign
  end

  def to_s
    display_name
  end
end
