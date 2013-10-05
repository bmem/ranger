class AssetUse < ActiveRecord::Base
  belongs_to :event
  belongs_to :asset
  belongs_to :involvement
  attr_accessible :asset_id, :checked_in, :checked_out, :due_in,
    :involvement_id, :extra, :note

  validates_presence_of :event, :asset, :involvement, :checked_out, :due_in
  validates_with DateOrderValidator, start: :checked_out, end: :checked_in
  validates_with DateOrderValidator, start: :checked_out, end: :due_in
  validates_with ReasonableDateValidator,
    attributes: [:checked_out, :checked_in, :due_in]
  validate :events_must_agree

  self.per_page = 100

  default_scope { order('checked_out DESC') }
  scope :currently_out, -> { where('checked_out IS NULL') }

  def currently_out?
    checked_in.nil?
  end

  def events_must_agree
    return unless involvement and asset
    errors.add(:involvement, 'Person involvement must be from event') unless
      event_id == involvement.event_id
    errors.add(:asset, 'Asset must be from event') unless
      event_id == asset.event_id
  end
end
