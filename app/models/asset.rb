class Asset < ActiveRecord::Base
  belongs_to :event
  has_many :asset_uses, dependent: :destroy
  attr_accessible :description, :designation, :name, :type

  validates :name, :type, :event_id, presence: true
  validates_uniqueness_of :name, scope: [:event_id, :type]
  validates_inclusion_of :designation, allow_blank: true, allow_nil: true,
    in: ->(asset) { asset.possible_designations }

  def possible_designations
    []
  end

  def possible_extras
    []
  end
end
