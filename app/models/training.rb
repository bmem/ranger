class Training < ActiveRecord::Base
  belongs_to :shift, :validate => true
  attr_accessible :instructions, :location, :map_link, :name, :shift_attributes
  accepts_nested_attributes_for :shift

  validates_presence_of :shift
  validates_each :training_season, :allow_nil => true do |record, attr, val|
    record.errors.add attr, 'is not a training event' unless val.is_a? TrainingSeason
  end

  def name
    shift && shift.name
  end

  def training_season_id
    shift && shift.event_id
  end

  def training_season
    shift && shift.event
  end

  def parent_records
    [training_season]
  end
end
