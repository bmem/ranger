class SlotTemplate < ActiveRecord::Base
  audited associated_with: :shift_template

  belongs_to :shift_template
  belongs_to :position
  attr_accessible :max_people, :min_people, :position_id, :shift_template_id

  validates :shift_template, :position, :presence => true
  # TODO same min/max validations as Slot

  def parent_records
    [shift_template]
  end

  def to_title
    position ? position.to_title : 'New slot template'
  end
end
