class Participant < ActiveRecord::Base
  STATUSES = [:planned, :confirmed, :bonked, :withdrawn]
  DETAIL_ATTRS = [
    :camp_location, :emergency_contact_info,
    :on_site_planned, :on_site_actual, :off_site_planned, :off_site_actual
  ]

  belongs_to :person
  belongs_to :event
  #has_and_belongs_to_many :positions, :through => :person
  has_and_belongs_to_many :slots
  has_many :work_logs

  store :details, :accesors => DETAIL_ATTRS

  validates :name, :full_name, :participation_status, :personnel_status,
    :presence => true
  validates_uniqueness_of :person_id, :scope => :event_id,
    :message => 'is already participating in this event'
  validates_uniqueness_of :name, :scope => :event_id
  validates :participation_status, :inclusion =>
    { :in => STATUSES.map(&:to_s), :message => "is not a valid status" }
  validates :personnel_status, :inclusion =>
    { :in => Person::STATUSES.map(&:to_s), :message => "is not a valid status" }

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
end
