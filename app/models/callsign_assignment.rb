class CallsignAssignment < ActiveRecord::Base
  audited associated_with: :callsign

  belongs_to :callsign, autosave: true
  belongs_to :person, autosave: true
  attr_accessible :end_date, :start_date, :primary_callsign

  #validates :callsign, :person, :start_date, presence: true
  validates :start_date, presence: true
  validates :primary_callsign, inclusion: {in: [true, false]}
  validates_with DateOrderValidator
  validates_with ReasonableDateValidator, attributes: [:start_date, :end_date],
    allow_future: false

  scope :current, -> {where('end_date IS NULL')}
  scope :primary, -> {where('primary_callsign')}

  def current?
    end_date.blank?
  end
end
