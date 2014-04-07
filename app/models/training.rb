class Training < ActiveRecord::Base
  belongs_to :shift, :validate => true
  has_and_belongs_to_many :arts
  has_one :training_season, :through => :shift, :source => :event

  attr_accessible :art_ids, :instructions, :location, :map_link, :name, :shift_attributes
  accepts_nested_attributes_for :shift

  audited associated_with: :shift

  validates_presence_of :shift
  validates_each :training_season, :allow_nil => true do |record, attr, val|
    record.errors.add attr, 'is not a training event' unless val.is_a? TrainingSeason
  end

  default_scope joins(:shift).readonly(false)

  def name
    shift && shift.name
  end

  def parent_records
    [training_season]
  end
end
