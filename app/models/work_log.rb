class WorkLog < ActiveRecord::Base
  belongs_to :participant
  belongs_to :position
  belongs_to :event
  belongs_to :shift

  validates_presence_of :participant, :position, :event, :start_time
end
