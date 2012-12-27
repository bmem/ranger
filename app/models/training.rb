class Training < ActiveRecord::Base
  belongs_to :training_season
  belongs_to :shift, :validate => true
  attr_accessible :instructions, :location, :map_link, :name, :shift_attributes
  accepts_nested_attributes_for :shift

  validates_presence_of :training_season, :shift, :name

  def parent_records
    [training_season]
  end
end
